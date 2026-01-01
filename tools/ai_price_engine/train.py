from __future__ import annotations

import argparse
import csv
import datetime as dt
import json
import math
import os
import random
from dataclasses import dataclass
from typing import Any

import server


@dataclass(frozen=True)
class TrainingRow:
    payload: dict[str, Any]
    y: float


def _percentile(sorted_values: list[float], q: float) -> float:
    if not sorted_values:
        raise ValueError("Empty list")
    q = max(0.0, min(1.0, q))
    idx = int(round(q * (len(sorted_values) - 1)))
    return sorted_values[idx]


def _pearson_r(xs: list[float], ys: list[float]) -> float | None:
    if len(xs) != len(ys) or len(xs) < 2:
        return None
    mx = sum(xs) / len(xs)
    my = sum(ys) / len(ys)
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    denx = math.sqrt(sum((x - mx) ** 2 for x in xs))
    deny = math.sqrt(sum((y - my) ** 2 for y in ys))
    if denx == 0 or deny == 0:
        return None
    return num / (denx * deny)


def _mae(y_true: list[float], y_pred: list[float]) -> float:
    return sum(abs(a - b) for a, b in zip(y_true, y_pred)) / max(1, len(y_true))


def _rmse(y_true: list[float], y_pred: list[float]) -> float:
    return math.sqrt(
        sum((a - b) ** 2 for a, b in zip(y_true, y_pred)) / max(1, len(y_true))
    )


def _mape(y_true: list[float], y_pred: list[float]) -> float:
    parts = []
    for a, b in zip(y_true, y_pred):
        if a == 0:
            continue
        parts.append(abs(a - b) / abs(a))
    return sum(parts) / max(1, len(parts))


def _solve_ridge(
    x_rows: list[list[float]],
    y: list[float],
    *,
    ridge_lambda: float,
) -> list[float]:
    """
    Solve (X^T X + λI) w = X^T y with a small, pure-Python Gaussian elimination.
    x_rows is n x p.
    """
    if not x_rows:
        raise ValueError("No training rows")
    p = len(x_rows[0])
    if p == 0:
        raise ValueError("No features")

    # A = X^T X
    a = [[0.0 for _ in range(p)] for __ in range(p)]
    b = [0.0 for _ in range(p)]  # X^T y

    for row, yi in zip(x_rows, y):
        for i in range(p):
            b[i] += row[i] * yi
            for j in range(p):
                a[i][j] += row[i] * row[j]

    for i in range(p):
        a[i][i] += ridge_lambda

    # Solve A w = b via Gaussian elimination with partial pivoting.
    aug = [a[i] + [b[i]] for i in range(p)]

    for col in range(p):
        pivot = max(range(col, p), key=lambda r: abs(aug[r][col]))
        if abs(aug[pivot][col]) < 1e-12:
            raise ValueError("Singular matrix (try increasing ridge_lambda)")
        if pivot != col:
            aug[col], aug[pivot] = aug[pivot], aug[col]

        pivot_val = aug[col][col]
        for j in range(col, p + 1):
            aug[col][j] /= pivot_val

        for r in range(p):
            if r == col:
                continue
            factor = aug[r][col]
            if factor == 0:
                continue
            for j in range(col, p + 1):
                aug[r][j] -= factor * aug[col][j]

    return [aug[i][p] for i in range(p)]


def _load_dataset(path: str) -> list[dict[str, Any]]:
    ext = os.path.splitext(path)[1].lower()
    if ext == ".json":
        with open(path, "r", encoding="utf-8") as f:
            raw = json.load(f)
        if isinstance(raw, list):
            return [r for r in raw if isinstance(r, dict)]
        if isinstance(raw, dict):
            rows = raw.get("rows")
            if isinstance(rows, list):
                return [r for r in rows if isinstance(r, dict)]
        raise ValueError("JSON dataset must be a list[object] or { rows: list[object] }")

    if ext == ".csv":
        with open(path, "r", encoding="utf-8-sig", newline="") as f:
            reader = csv.DictReader(f)
            return [dict(r) for r in reader]

    raise ValueError("Unsupported dataset format (use .csv or .json)")


def _parse_row(row: dict[str, Any]) -> TrainingRow | None:
    """
    Create a payload compatible with server.recommend + extract label.

    Required:
    - actual_best_price
    - competitor_avg OR competitor_prices (list)
    - cost_price (>0) OR min_price (>0)
    """
    y = server._to_float(row.get("actual_best_price") or row.get("label") or row.get("y"))
    if y is None or y <= 0:
        return None

    payload: dict[str, Any] = {}

    def put_num(key: str, value: Any) -> None:
        if key not in row or value is None or value == "":
            return
        f = server._to_float(value)
        if f is None:
            return
        payload[key] = f

    for k in (
        "competitor_avg",
        "cost_price",
        "desired_margin",
        "demand_factor",
        "current_price",
        "min_price",
        "shipping_cost",
        "platform_fee_pct",
        "sales_velocity",
        "stock_level",
        "rating",
        "promo_factor",
        "seasonality_factor",
        "market_sample_size",
    ):
        put_num(k, row.get(k))

    # competitor_prices supports: JSON list string, comma-separated list, or list (JSON dataset).
    comp_prices = row.get("competitor_prices")
    if isinstance(comp_prices, list):
        payload["competitor_prices"] = comp_prices
    elif isinstance(comp_prices, str) and comp_prices.strip():
        s = comp_prices.strip()
        parsed_list: list[Any] | None = None
        if s.startswith("[") and s.endswith("]"):
            try:
                parsed_list = json.loads(s)
            except json.JSONDecodeError:
                parsed_list = None
        if parsed_list is None:
            parts = [p.strip() for p in s.split(",") if p.strip()]
            parsed_list = parts
        payload["competitor_prices"] = parsed_list

    # Ensure we have a usable competitor signal for training.
    has_comp = False
    if server._to_float(payload.get("competitor_avg")) and payload["competitor_avg"] > 0:
        has_comp = True
    if isinstance(payload.get("competitor_prices"), list) and payload["competitor_prices"]:
        has_comp = True
    if not has_comp:
        return None

    # Ensure we have a usable floor for training.
    min_price = server._to_float(payload.get("min_price"))
    cost_price = server._to_float(payload.get("cost_price"))
    if min_price is None and (cost_price is None or cost_price <= 0):
        return None

    return TrainingRow(payload=payload, y=y)


def _build_features(rows: list[TrainingRow]) -> tuple[list[list[float]], list[float], dict[str, float]]:
    """
    Build linear features matching the deployed formula:
      y ≈ alpha*Pc + beta*min_price + gamma_multiplier*(Pc*demand_effective)
    """
    xs: list[list[float]] = []
    ys: list[float] = []

    demand_values: list[float] = []
    ratios: list[float] = []

    weights = server._load_weights(os.path.join(os.path.dirname(__file__), "weights.json"))

    for tr in rows:
        payload = dict(tr.payload)
        # Use server logic to compute the same min_price + demand_effective used in recommend().
        # We call the internal helpers to avoid parsing strictness.
        cost_price = server._to_float(payload.get("cost_price"))
        desired_margin = server._to_float(payload.get("desired_margin")) or 0.0
        shipping_cost = server._to_float(payload.get("shipping_cost")) or 0.0
        platform_fee_pct = server._to_float(payload.get("platform_fee_pct")) or 0.0
        min_price_input = server._to_float(payload.get("min_price"))

        try:
            min_price, _ = server._compute_min_price(
                cost_price=cost_price,
                desired_margin=desired_margin,
                min_price_input=min_price_input,
                shipping_cost=shipping_cost,
                platform_fee_pct=platform_fee_pct,
            )
        except server.InputError:
            continue

        # Competitor avg (robust if list provided).
        competitor_avg = server._to_float(payload.get("competitor_avg"))
        if competitor_avg is None or competitor_avg <= 0:
            comp_prices_raw = payload.get("competitor_prices")
            comp_prices: list[float] = []
            if isinstance(comp_prices_raw, list):
                for x in comp_prices_raw:
                    f = server._to_float(x)
                    if f is not None and f > 0:
                        comp_prices.append(f)
            if not comp_prices:
                continue
            competitor_avg, _ = server._robust_price_average(comp_prices)

        demand_factor = server._to_float(payload.get("demand_factor"))
        if demand_factor is None:
            demand_factor = 0.5
        if demand_factor > 1:
            demand_factor = demand_factor / 100.0
        demand_factor = server._clamp(demand_factor, 0.0, 1.0)
        demand_values.append(demand_factor)

        # Match server's demand_effective adjustment (sales_velocity + rating).
        sales_velocity = server._to_float(payload.get("sales_velocity"))
        rating = server._to_float(payload.get("rating"))

        sales_norm = None
        if sales_velocity is not None:
            sales_norm = server._log_norm(
                max(0.0, sales_velocity),
                float(weights.get("sales_velocity_ref", 50.0)),
            )

        rating_norm = None
        if rating is not None:
            rating_norm = server._clamp(rating / 5.0, 0.0, 1.0)

        demand_effective = demand_factor
        if sales_norm is not None:
            w = float(weights.get("sales_velocity_weight", 0.12))
            demand_effective += w * ((sales_norm - 0.5) * 2.0)
        if rating_norm is not None:
            w = float(weights.get("rating_weight", 0.08))
            demand_effective += w * ((rating_norm - 0.5) * 2.0)
        demand_effective = server._clamp(demand_effective, 0.0, 1.0)

        xs.append([competitor_avg, min_price, competitor_avg * demand_effective])
        ys.append(tr.y)

        if competitor_avg > 0:
            ratios.append((tr.y / competitor_avg) - 1.0)

    # Defaults derived from the dataset.
    demand_default = 0.5
    if demand_values:
        demand_values_sorted = sorted(demand_values)
        demand_default = float(_percentile(demand_values_sorted, 0.5))

    ceiling_pct = 0.07
    if ratios:
        ratios_sorted = sorted(ratios)
        p95 = _percentile(ratios_sorted, 0.95)
        ceiling_pct = float(server._clamp(max(0.0, p95), 0.0, 0.3))
        ceiling_pct = max(0.05, ceiling_pct)

    return xs, ys, {"demand_default": demand_default, "competitive_ceiling_pct": ceiling_pct}


def _scale_features(xs: list[list[float]]) -> tuple[list[list[float]], list[float]]:
    # Robust feature scaling to improve numeric stability.
    p = len(xs[0])
    scales = []
    for j in range(p):
        col = sorted(abs(r[j]) for r in xs)
        scale = _percentile(col, 0.95)
        scales.append(scale if scale > 1e-6 else 1.0)
    xs_scaled = [[r[j] / scales[j] for j in range(p)] for r in xs]
    return xs_scaled, scales


def main() -> None:
    parser = argparse.ArgumentParser(description="Train AI Price Engine weights from CSV/JSON data.")
    parser.add_argument("--data", required=True, help="Path to dataset (.csv or .json)")
    parser.add_argument(
        "--out",
        default=os.path.join(os.path.dirname(__file__), "weights.json"),
        help="Output weights.json path",
    )
    parser.add_argument("--ridge", type=float, default=1e-2, help="Ridge lambda (L2)")
    parser.add_argument("--val-split", type=float, default=0.2, help="Validation split fraction")
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    raw_rows = _load_dataset(args.data)
    parsed_rows = [r for r in (_parse_row(rr) for rr in raw_rows) if r is not None]
    if len(parsed_rows) < 20:
        raise SystemExit(f"Not enough valid rows for training: {len(parsed_rows)}")

    random.Random(args.seed).shuffle(parsed_rows)
    val_n = max(1, int(len(parsed_rows) * server._clamp(args.val_split, 0.05, 0.5)))
    val_rows = parsed_rows[:val_n]
    train_rows = parsed_rows[val_n:]

    xs, ys, defaults = _build_features(train_rows)
    if len(xs) < 10:
        raise SystemExit(f"Not enough usable rows after feature build: {len(xs)}")

    xs_scaled, scales = _scale_features(xs)

    w_scaled = _solve_ridge(xs_scaled, ys, ridge_lambda=max(0.0, args.ridge))
    w = [w_scaled[j] / scales[j] for j in range(len(w_scaled))]

    alpha_raw, beta_raw, gamma_multiplier_raw = w[0], w[1], w[2]

    base_weights = server._load_weights(args.out)
    trained = server._sanitize_weights(
        {
            **base_weights,
            "model_version": "mock-formula-v2",
            "alpha": alpha_raw,
            "beta": beta_raw,
            "gamma_multiplier": gamma_multiplier_raw,
            "competitive_ceiling_pct": defaults["competitive_ceiling_pct"],
            "demand_default": defaults["demand_default"],
        }
    )

    # Surface any big post-sanitize changes (negative weights, clamping, renormalization).
    deltas = {
        "alpha": float(trained["alpha"]) - alpha_raw,
        "beta": float(trained["beta"]) - beta_raw,
        "gamma_multiplier": float(trained["gamma_multiplier"]) - gamma_multiplier_raw,
    }
    sanitize_warnings: list[str] = []
    if alpha_raw < 0 or beta_raw < 0:
        sanitize_warnings.append("alpha/beta had negative values; clamped + renormalized.")
    if gamma_multiplier_raw < 0:
        sanitize_warnings.append("gamma_multiplier was negative; clamped to 0.")
    if gamma_multiplier_raw > 0.2:
        sanitize_warnings.append("gamma_multiplier exceeded 0.2; clamped.")
    if abs(deltas["alpha"]) > 0.05 or abs(deltas["beta"]) > 0.05:
        sanitize_warnings.append("alpha/beta changed noticeably after renormalization.")

    # Evaluate on validation with the deployed recommend() (includes clamps + confidence).
    y_true: list[float] = []
    y_pred: list[float] = []
    confidences: list[float] = []
    abs_errors: list[float] = []

    for tr in val_rows:
        try:
            res = server.recommend(tr.payload, trained, explain=False)
        except server.InputError:
            continue
        pred = float(res["recommended_price"])
        conf = float(res["confidence"])
        y_true.append(tr.y)
        y_pred.append(pred)
        confidences.append(conf)
        abs_errors.append(abs(pred - tr.y))

    metrics = {
        "mae": round(_mae(y_true, y_pred), 6),
        "rmse": round(_rmse(y_true, y_pred), 6),
        "mape": round(_mape(y_true, y_pred), 6),
    }

    r_conf_err = _pearson_r(confidences, abs_errors)

    # Confidence buckets (quartiles) for a quick calibration sanity check.
    buckets = []
    if confidences:
        paired = sorted(zip(confidences, abs_errors), key=lambda t: t[0])
        q = max(1, len(paired) // 4)
        for i in range(4):
            chunk = paired[i * q : (i + 1) * q] if i < 3 else paired[i * q :]
            if not chunk:
                continue
            avg_conf = sum(c for c, _ in chunk) / len(chunk)
            avg_err = sum(e for _, e in chunk) / len(chunk)
            buckets.append(
                {"avg_confidence": round(avg_conf, 4), "mae": round(avg_err, 6), "n": len(chunk)}
            )

    today = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%d")
    model_version = f"mock-formula-v2-trained-{today}"

    out = dict(trained)
    out["model_version"] = model_version
    out["training"] = {
        "timestamp_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "dataset": os.path.basename(args.data),
        "rows_total": len(raw_rows),
        "rows_parsed": len(parsed_rows),
        "rows_train": len(train_rows),
        "rows_val": len(val_rows),
        "ridge_lambda": max(0.0, args.ridge),
        "val_split": server._clamp(args.val_split, 0.05, 0.5),
        "features": ["competitor_avg", "min_price", "competitor_avg*demand_effective"],
        "metrics_val": metrics,
        "confidence_calibration": {
            "pearson_r_conf_abs_error": None if r_conf_err is None else round(r_conf_err, 6),
            "quartiles": buckets,
        },
    }

    os.makedirs(os.path.dirname(args.out) or ".", exist_ok=True)
    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)
        f.write("\n")

    print("Saved weights:", args.out)
    print("Model version:", model_version)
    print("Learned (sanitized):")
    print(f"  alpha: {out['alpha']:.6f}")
    print(f"  beta: {out['beta']:.6f}")
    print(f"  gamma_multiplier: {out['gamma_multiplier']:.6f}")
    print(f"  competitive_ceiling_pct: {out['competitive_ceiling_pct']:.6f}")
    print(f"  demand_default: {out['demand_default']:.6f}")
    print("Validation metrics:", metrics)
    if r_conf_err is not None:
        print(
            f"Confidence calibration (pearson r vs abs error): {r_conf_err:.4f} (negative is better)"
        )
    if sanitize_warnings:
        print("Sanity warnings:")
        for w in sanitize_warnings:
            print(f"  - {w}")


if __name__ == "__main__":
    main()
