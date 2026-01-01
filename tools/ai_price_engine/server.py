from __future__ import annotations

import argparse
import json
import math
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any


def _clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, value))


def _to_float(value: Any) -> float | None:
    try:
        if value is None:
            return None
        return float(value)
    except (TypeError, ValueError):
        return None


def _load_weights(path: str) -> dict[str, Any]:
    defaults: dict[str, Any] = {
        "model_version": "mock-formula-v1",
        "alpha": 0.65,
        "beta": 0.35,
        "gamma_multiplier": 0.05,
        "competitive_ceiling_pct": 0.05,
        "demand_default": 0.5,
    }

    try:
        with open(path, "r", encoding="utf-8") as f:
            raw = json.load(f)
        if isinstance(raw, dict):
            return {**defaults, **raw}
    except OSError:
        return defaults
    except json.JSONDecodeError:
        return defaults

    return defaults


def recommend(payload: dict[str, Any], weights: dict[str, Any]) -> dict[str, Any]:
    competitor_avg = _to_float(payload.get("competitor_avg"))
    cost_price = _to_float(payload.get("cost_price")) or 0.0
    desired_margin = _to_float(payload.get("desired_margin")) or 0.0
    current_price = _to_float(payload.get("current_price")) or 0.0

    if desired_margin > 1:
        desired_margin = desired_margin / 100.0

    min_price = _to_float(payload.get("min_price"))
    if min_price is None:
        min_price = cost_price * (1.0 + max(0.0, desired_margin))

    demand_factor = _to_float(payload.get("demand_factor"))
    if demand_factor is None:
        demand_factor = float(weights.get("demand_default", 0.5))
    demand_factor = _clamp(demand_factor, 0.0, 1.0)

    alpha = float(weights.get("alpha", 0.65))
    beta = float(weights.get("beta", 0.35))
    gamma_multiplier = float(weights.get("gamma_multiplier", 0.05))

    if competitor_avg is None or competitor_avg <= 0:
        candidate = max(min_price, current_price if current_price > 0 else min_price)
        confidence = 0.55
        return {
            "recommended_price": round(candidate, 2),
            "confidence": confidence,
            "model_version": str(weights.get("model_version", "mock-formula-v1")),
        }

    gamma = gamma_multiplier * competitor_avg
    candidate = (alpha * competitor_avg) + (beta * min_price) + (gamma * demand_factor)

    ceiling_pct = float(weights.get("competitive_ceiling_pct", 0.05))
    ceiling = max(min_price, competitor_avg * (1.0 + max(0.0, ceiling_pct)))
    candidate = _clamp(candidate, min_price, ceiling)

    # Simple, explainable confidence: better when we have market + demand inputs.
    confidence = 0.65 + (0.2 * demand_factor)
    confidence = _clamp(confidence, 0.0, 1.0)

    return {
        "recommended_price": round(candidate, 2),
        "confidence": round(confidence, 4),
        "model_version": str(weights.get("model_version", "mock-formula-v1")),
    }


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
        if self.path == "/health":
            self._send_json(200, {"status": "ok"})
            return
        self._send_json(404, {"message": "Not found"})

    def do_POST(self) -> None:  # noqa: N802
        if self.path not in ("/", "/recommend", "/v1/recommend"):
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

        result = recommend(body, self.weights)
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

