from __future__ import annotations

import argparse
import json
import math
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any
from urllib.parse import parse_qs, urlsplit


def _clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, value))


def _to_float(value: Any) -> float | None:
    try:
        if value is None:
            return None
        f = float(value)
        if not math.isfinite(f):
            return None
        return f
    except (TypeError, ValueError):
        return None


def _parse_optional_float(payload: dict[str, Any], key: str) -> float | None:
    if key not in payload:
        return None
    raw = payload.get(key)
    if raw is None:
        return None
    parsed = _to_float(raw)
    if parsed is None:
        raise InputError("Invalid numeric inputs", {key: "Must be a finite number"})
    return parsed


class InputError(Exception):
    def __init__(self, message: str, errors: dict[str, str] | None = None):
        super().__init__(message)
        self.message = message
        self.errors = errors or {}


def _as_percent(value: float) -> float:
    if value > 1.0:
        return value / 100.0
    return value


def _median(values: list[float]) -> float:
    values = sorted(values)
    mid = len(values) // 2
    if len(values) % 2 == 1:
        return values[mid]
    return (values[mid - 1] + values[mid]) / 2.0


def _robust_price_average(values: list[float]) -> tuple[float, str]:
    """
    Robust competitor aggregator:
    - n < 5: median (stable for small samples)
    - n >= 5: 10% trimmed mean
    """
    values = [v for v in values if v > 0 and math.isfinite(v)]
    if not values:
        raise ValueError("No valid competitor prices")

    n = len(values)
    if n < 5:
        return _median(values), "median"

    values = sorted(values)
    trim = max(1, int(n * 0.1))
    core = values[trim : n - trim]
    if not core:
        return _median(values), "median_fallback"
    return sum(core) / len(core), "trimmed_mean_10pct"


def _boolish(value: Any) -> bool:
    if isinstance(value, bool):
        return value
    if value is None:
        return False
    if isinstance(value, (int, float)):
        return value != 0
    if isinstance(value, str):
        return value.strip().lower() in {"1", "true", "yes", "y", "on"}
    return False


def _sanitize_weights(raw: dict[str, Any]) -> dict[str, Any]:
    """
    Enforce stability constraints:
    - alpha,beta: non-negative and sum to 1
    - gamma_multiplier: [0, 0.2]
    - competitive_ceiling_pct: [0, 0.3]
    - demand_default: [0, 1]
    - current_price_smoothing: [0, 0.3]
    """
    model_version = str(raw.get("model_version", "mock-formula-v2"))

    alpha = _to_float(raw.get("alpha")) or 0.65
    beta = _to_float(raw.get("beta")) or 0.35

    alpha = max(0.0, alpha)
    beta = max(0.0, beta)
    if alpha == 0 and beta == 0:
        alpha, beta = 0.65, 0.35
    else:
        total = alpha + beta
        alpha, beta = alpha / total, beta / total

    gamma_multiplier = _clamp(_to_float(raw.get("gamma_multiplier")) or 0.05, 0.0, 0.2)
    ceiling_pct = _clamp(_to_float(raw.get("competitive_ceiling_pct")) or 0.07, 0.0, 0.3)
    demand_default = _clamp(_to_float(raw.get("demand_default")) or 0.5, 0.0, 1.0)

    sales_velocity_ref = max(1.0, _to_float(raw.get("sales_velocity_ref")) or 50.0)
    sales_velocity_weight = _clamp(_to_float(raw.get("sales_velocity_weight")) or 0.12, 0.0, 0.25)

    stock_level_ref = max(1.0, _to_float(raw.get("stock_level_ref")) or 200.0)
    stock_multiplier_max_delta = _clamp(
        _to_float(raw.get("stock_multiplier_max_delta")) or 0.08,
        0.0,
        0.15,
    )

    rating_weight = _clamp(_to_float(raw.get("rating_weight")) or 0.08, 0.0, 0.25)
    current_price_smoothing = _clamp(
        _to_float(raw.get("current_price_smoothing")) or 0.10,
        0.0,
        0.30,
    )

    # Keep unknown keys (like training metadata) but override sanitized core keys.
    return {
        **raw,
        "model_version": model_version,
        "alpha": alpha,
        "beta": beta,
        "gamma_multiplier": gamma_multiplier,
        "competitive_ceiling_pct": ceiling_pct,
        "demand_default": demand_default,
        "sales_velocity_ref": sales_velocity_ref,
        "sales_velocity_weight": sales_velocity_weight,
        "stock_level_ref": stock_level_ref,
        "stock_multiplier_max_delta": stock_multiplier_max_delta,
        "rating_weight": rating_weight,
        "current_price_smoothing": current_price_smoothing,
    }


def _load_weights(path: str) -> dict[str, Any]:
    defaults: dict[str, Any] = _sanitize_weights(
        {
            "model_version": "mock-formula-v2",
            "alpha": 0.65,
            "beta": 0.35,
            "gamma_multiplier": 0.05,
            "competitive_ceiling_pct": 0.07,
            "demand_default": 0.5,
            "sales_velocity_ref": 50.0,
            "sales_velocity_weight": 0.12,
            "stock_level_ref": 200.0,
            "stock_multiplier_max_delta": 0.08,
            "rating_weight": 0.08,
            "current_price_smoothing": 0.10,
        }
    )

    try:
        with open(path, "r", encoding="utf-8") as f:
            raw = json.load(f)
        if isinstance(raw, dict):
            return _sanitize_weights({**defaults, **raw})
    except OSError:
        return defaults
    except json.JSONDecodeError:
        return defaults

    return defaults


def _log_norm(value: float, ref: float) -> float:
    if value <= 0:
        return 0.0
    return _clamp(math.log1p(value) / math.log1p(ref), 0.0, 1.0)


def _compute_min_price(
    *,
    cost_price: float | None,
    desired_margin: float,
    min_price_input: float | None,
    shipping_cost: float,
    platform_fee_pct: float,
) -> tuple[float, dict[str, Any]]:
    desired_margin = _clamp(_as_percent(desired_margin), 0.0, 1.0)
    platform_fee_pct = _clamp(_as_percent(platform_fee_pct), 0.0, 0.3)
    shipping_cost = max(0.0, shipping_cost)

    computed_floor = None
    if cost_price is not None and cost_price > 0:
        subtotal_cost = max(0.0, cost_price) + shipping_cost
        fee_divisor = max(0.01, 1.0 - platform_fee_pct)
        computed_floor = (subtotal_cost / fee_divisor) * (1.0 + desired_margin)

    if min_price_input is None:
        if computed_floor is None:
            raise InputError(
                "Missing required pricing inputs",
                {"min_price": "Provide min_price, or provide cost_price (>0) to compute it."},
            )
        min_price_used = computed_floor
        source = "computed"
    else:
        if min_price_input <= 0:
            raise InputError(
                "Invalid numeric inputs",
                {"min_price": "min_price must be > 0"},
            )
        source = "provided"
        min_price_used = min_price_input
        if computed_floor is not None and computed_floor > min_price_used:
            min_price_used = computed_floor
            source = "max(provided, computed)"

    return float(min_price_used), {
        "min_price_source": source,
        "desired_margin": desired_margin,
        "platform_fee_pct": platform_fee_pct,
        "shipping_cost": shipping_cost,
        "computed_floor": None if computed_floor is None else round(float(computed_floor), 6),
    }


def recommend(
    payload: dict[str, Any],
    weights: dict[str, Any],
    *,
    explain: bool = False,
) -> dict[str, Any]:
    # Required-ish inputs (for a sensible floor).
    cost_price = _parse_optional_float(payload, "cost_price")
    desired_margin = _parse_optional_float(payload, "desired_margin") or 0.0
    current_price = _parse_optional_float(payload, "current_price") or 0.0

    # Optional additional costs / constraints.
    shipping_cost = _parse_optional_float(payload, "shipping_cost") or 0.0
    platform_fee_pct = _parse_optional_float(payload, "platform_fee_pct") or 0.0

    invalids: dict[str, str] = {}
    if cost_price is not None and cost_price < 0:
        invalids["cost_price"] = "Must be >= 0"
    if desired_margin < 0:
        invalids["desired_margin"] = "Must be >= 0"
    if current_price < 0:
        invalids["current_price"] = "Must be >= 0"
    if shipping_cost < 0:
        invalids["shipping_cost"] = "Must be >= 0"
    if platform_fee_pct < 0:
        invalids["platform_fee_pct"] = "Must be >= 0"
    if invalids:
        raise InputError("Invalid numeric inputs", invalids)

    min_price_input = _parse_optional_float(payload, "min_price")
    min_price, min_debug = _compute_min_price(
        cost_price=cost_price,
        desired_margin=desired_margin,
        min_price_input=min_price_input,
        shipping_cost=shipping_cost,
        platform_fee_pct=platform_fee_pct,
    )

    # Market competitor signal: accept either a precomputed avg or a list of samples.
    competitor_avg = _parse_optional_float(payload, "competitor_avg")
    competitor_prices_raw = payload.get("competitor_prices")
    competitor_prices: list[float] = []
    if competitor_prices_raw is not None:
        if not isinstance(competitor_prices_raw, list):
            raise InputError(
                "Invalid numeric inputs",
                {"competitor_prices": "Must be a list of numbers"},
            )
        for x in competitor_prices_raw:
            if x is None:
                continue
            parsed = _to_float(x)
            if parsed is None:
                raise InputError(
                    "Invalid numeric inputs",
                    {"competitor_prices": "List contains a non-numeric value"},
                )
            if parsed > 0:
                competitor_prices.append(parsed)
        if competitor_prices_raw and not competitor_prices:
            raise InputError(
                "Invalid numeric inputs",
                {"competitor_prices": "Must include at least one positive number"},
            )

    competitor_method = "avg"
    competitor_sample_size = 0
    competitor_avg_used = competitor_avg if competitor_avg and competitor_avg > 0 else None
    if competitor_prices:
        competitor_avg_used, competitor_method = _robust_price_average(competitor_prices)
        competitor_sample_size = len(competitor_prices)

    market_sample_size = int(_parse_optional_float(payload, "market_sample_size") or 0)
    market_sample_size = max(competitor_sample_size, market_sample_size)

    # Demand signal.
    demand_default = float(weights.get("demand_default", 0.5))
    demand_factor = _parse_optional_float(payload, "demand_factor")
    demand_source = "provided"
    if demand_factor is None:
        demand_source = "default"
        demand_factor = demand_default
    if demand_factor > 1:
        demand_factor = demand_factor / 100.0
    demand_factor = _clamp(demand_factor, 0.0, 1.0)

    # Optional extra features (bounded + explainable).
    sales_velocity = _parse_optional_float(payload, "sales_velocity")
    stock_level = _parse_optional_float(payload, "stock_level")
    rating = _parse_optional_float(payload, "rating")

    promo_factor = _parse_optional_float(payload, "promo_factor")
    seasonality_factor = _parse_optional_float(payload, "seasonality_factor")

    sales_norm = None
    if sales_velocity is not None:
        sales_norm = _log_norm(max(0.0, sales_velocity), float(weights.get("sales_velocity_ref", 50.0)))

    rating_norm = None
    if rating is not None:
        rating_norm = _clamp(rating / 5.0, 0.0, 1.0)

    demand_effective = demand_factor
    if sales_norm is not None:
        w = float(weights.get("sales_velocity_weight", 0.12))
        demand_effective += w * ((sales_norm - 0.5) * 2.0)

    if rating_norm is not None:
        w = float(weights.get("rating_weight", 0.08))
        demand_effective += w * ((rating_norm - 0.5) * 2.0)

    demand_effective = _clamp(demand_effective, 0.0, 1.0)

    stock_norm = None
    stock_multiplier = 1.0
    if stock_level is not None:
        stock_norm = _log_norm(max(0.0, stock_level), float(weights.get("stock_level_ref", 200.0)))
        max_delta = float(weights.get("stock_multiplier_max_delta", 0.08))
        delta = max_delta * ((0.5 - stock_norm) * 2.0)
        stock_multiplier = _clamp(1.0 + delta, 1.0 - max_delta, 1.0 + max_delta)

    promo_multiplier = 1.0
    if promo_factor is not None:
        if promo_factor >= 1.5 and promo_factor <= 100:
            promo_multiplier = 1.0 - (promo_factor / 100.0)
        else:
            promo_multiplier = promo_factor
        promo_multiplier = _clamp(promo_multiplier, 0.70, 1.20)

    seasonality_multiplier = 1.0
    if seasonality_factor is not None:
        seasonality_multiplier = _clamp(seasonality_factor, 0.85, 1.15)

    # Candidate computation (core explainable formula).
    alpha = float(weights.get("alpha", 0.65))
    beta = float(weights.get("beta", 0.35))
    gamma_multiplier = float(weights.get("gamma_multiplier", 0.05))
    ceiling_pct = float(weights.get("competitive_ceiling_pct", 0.07))
    smoothing = float(weights.get("current_price_smoothing", 0.10))

    clamps: dict[str, bool] = {
        "min_price": False,
        "ceiling": False,
    }

    if competitor_avg_used is None or competitor_avg_used <= 0:
        base = current_price if current_price > 0 else min_price
        candidate_raw = max(min_price, base)
        candidate_adj = candidate_raw * stock_multiplier * promo_multiplier * seasonality_multiplier
        candidate_smoothed = candidate_adj
        if current_price > 0 and smoothing > 0:
            candidate_smoothed = (1.0 - smoothing) * candidate_adj + (smoothing * current_price)
        if not math.isfinite(candidate_smoothed):
            raise InputError("Numeric overflow", {"recommended_price": "Computation produced a non-finite value"})
        candidate = max(min_price, candidate_smoothed)
        if candidate <= min_price + 1e-9:
            clamps["min_price"] = True

        confidence_quality = 0.30 + 0.20 * (1.0 if demand_source == "provided" else 0.6)
        confidence = _clamp(0.35 + 0.6 * confidence_quality, 0.0, 1.0)

        result: dict[str, Any] = {
            "recommended_price": round(candidate, 2),
            "confidence": round(confidence, 4),
            "model_version": str(weights.get("model_version", "mock-formula-v2")),
        }

        if explain:
            result["explain"] = {
                "competitor_avg_used": None,
                "competitor_method": None,
                "min_price": round(min_price, 6),
                "ceiling": None,
                "demand_factor_used": round(demand_factor, 6),
                "demand_effective": round(demand_effective, 6),
                "clamps": clamps,
                "components": {
                    "fallback_base": round(base, 6),
                },
                "multipliers": {
                    "stock_multiplier": round(stock_multiplier, 6),
                    "promo_multiplier": round(promo_multiplier, 6),
                    "seasonality_multiplier": round(seasonality_multiplier, 6),
                    "current_price_smoothing": round(smoothing, 6),
                },
                "inputs": {
                    "current_price": round(current_price, 6),
                    "cost_price": None if cost_price is None else round(cost_price, 6),
                    **min_debug,
                },
            }
        return result

    gamma = gamma_multiplier * competitor_avg_used
    comp_component = alpha * competitor_avg_used
    min_component = beta * min_price
    demand_component = gamma * demand_effective

    candidate_raw = comp_component + min_component + demand_component
    candidate_adj = candidate_raw * stock_multiplier * promo_multiplier * seasonality_multiplier

    candidate_smoothed = candidate_adj
    if current_price > 0 and smoothing > 0:
        candidate_smoothed = (1.0 - smoothing) * candidate_adj + (smoothing * current_price)

    if not math.isfinite(candidate_smoothed):
        raise InputError("Numeric overflow", {"recommended_price": "Computation produced a non-finite value"})

    ceiling = max(min_price, competitor_avg_used * (1.0 + max(0.0, ceiling_pct)))
    if not math.isfinite(ceiling):
        raise InputError("Numeric overflow", {"ceiling": "Computation produced a non-finite value"})
    candidate = _clamp(candidate_smoothed, min_price, ceiling)
    if candidate <= min_price + 1e-9:
        clamps["min_price"] = True
    if candidate >= ceiling - 1e-9:
        clamps["ceiling"] = True

    # Confidence: reflect signal quality, not raw demand magnitude.
    competitor_quality = 0.6
    if market_sample_size > 0:
        competitor_quality = _clamp(math.log1p(market_sample_size) / math.log1p(10.0), 0.0, 1.0)

    demand_quality = 1.0 if demand_source == "provided" else 0.7

    extras_present = sum(
        1
        for v in (sales_velocity, stock_level, rating, shipping_cost, platform_fee_pct)
        if v is not None and v != 0
    )
    extras_quality = _clamp(extras_present / 5.0, 0.0, 1.0)

    quality = (0.55 * competitor_quality) + (0.25 * demand_quality) + (0.20 * extras_quality)
    confidence = 0.35 + (0.6 * quality)
    confidence -= 0.05 if clamps["min_price"] else 0.0
    confidence -= 0.05 if clamps["ceiling"] else 0.0
    confidence = _clamp(confidence, 0.0, 1.0)

    result = {
        "recommended_price": round(candidate, 2),
        "confidence": round(confidence, 4),
        "model_version": str(weights.get("model_version", "mock-formula-v2")),
    }

    if explain:
        result["explain"] = {
            "competitor_avg_used": round(float(competitor_avg_used), 6),
            "competitor_method": competitor_method,
            "market_sample_size": market_sample_size,
            "min_price": round(min_price, 6),
            "ceiling": round(float(ceiling), 6),
            "demand_factor_used": round(demand_factor, 6),
            "demand_effective": round(demand_effective, 6),
            "clamps": clamps,
            "components": {
                "alpha_component": round(float(comp_component), 6),
                "beta_component": round(float(min_component), 6),
                "gamma_component": round(float(demand_component), 6),
                "candidate_raw": round(float(candidate_raw), 6),
            },
            "multipliers": {
                "stock_multiplier": round(stock_multiplier, 6),
                "promo_multiplier": round(promo_multiplier, 6),
                "seasonality_multiplier": round(seasonality_multiplier, 6),
                "current_price_smoothing": round(smoothing, 6),
                "candidate_after_multipliers": round(float(candidate_adj), 6),
                "candidate_after_smoothing": round(float(candidate_smoothed), 6),
            },
            "normalized_features": {
                "sales_velocity_norm": None if sales_norm is None else round(float(sales_norm), 6),
                "stock_level_norm": None if stock_norm is None else round(float(stock_norm), 6),
                "rating_norm": None if rating_norm is None else round(float(rating_norm), 6),
            },
            "weights_used": {
                "alpha": round(alpha, 6),
                "beta": round(beta, 6),
                "gamma_multiplier": round(gamma_multiplier, 6),
                "competitive_ceiling_pct": round(ceiling_pct, 6),
                "demand_default": round(demand_default, 6),
            },
            "inputs": {
                "current_price": round(current_price, 6),
                "cost_price": None if cost_price is None else round(cost_price, 6),
                **min_debug,
                "demand_source": demand_source,
            },
            "confidence": {
                "competitor_quality": round(competitor_quality, 6),
                "demand_quality": round(demand_quality, 6),
                "extras_quality": round(extras_quality, 6),
                "quality": round(quality, 6),
            },
        }

    return result


class Handler(BaseHTTPRequestHandler):
    weights: dict[str, Any] = {}

    def _send_json(self, status: int, data: dict[str, Any]) -> None:
        payload = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self) -> None:  # noqa: N802
        parsed = urlsplit(self.path)
        if parsed.path == "/health":
            self._send_json(200, {"status": "ok"})
            return
        if parsed.path == "/v1/weights":
            # Safe: contains only coefficients and training metadata (no secrets).
            self._send_json(200, {"weights": self.weights})
            return
        self._send_json(404, {"message": "Not found"})

    def do_POST(self) -> None:  # noqa: N802
        parsed = urlsplit(self.path)
        if parsed.path not in ("/", "/recommend", "/v1/recommend"):
            self._send_json(404, {"message": "Not found"})
            return

        length = int(self.headers.get("Content-Length") or 0)
        raw = self.rfile.read(length) if length > 0 else b"{}"

        try:
            body = json.loads(raw.decode("utf-8") or "{}")
        except json.JSONDecodeError:
            self._send_json(400, {"message": "Invalid JSON"})
            return

        if not isinstance(body, dict):
            self._send_json(400, {"message": "JSON body must be an object"})
            return

        query = parse_qs(parsed.query)
        explain_qs = query.get("explain", ["0"])[0] if query else "0"
        want_explain = _boolish(body.get("explain")) or _boolish(explain_qs)

        try:
            result = recommend(body, self.weights, explain=want_explain)
        except InputError as e:
            self._send_json(400, {"message": e.message, "errors": e.errors})
            return
        except Exception as e:  # pragma: no cover
            self._send_json(500, {"message": "Internal error", "error": str(e)})
            return

        self._send_json(200, result)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=9010)
    parser.add_argument(
        "--weights",
        default=os.path.join(os.path.dirname(__file__), "weights.json"),
        help="Path to weights.json",
    )
    args = parser.parse_args()

    weights = _load_weights(args.weights)
    Handler.weights = weights

    server = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f"AI Price Engine listening on http://{args.host}:{args.port}")
    print(f"Using weights: {args.weights}")
    server.serve_forever()


if __name__ == "__main__":
    main()
