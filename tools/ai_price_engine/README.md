# AI Price Engine (Guest-safe, Explainable, Deployable)

This is a small local HTTP service that Laravel can call via `AI_PRICE_ENGINE_URL`.

It implements a **simple, explainable pricing formula** (v2) with:
- A break-even **min price floor** (cost + shipping + platform fees + target margin)
- A robust competitor signal (avg or median/trimmed-mean from a list)
- A bounded demand/stock adjustment
- Hard safety clamps: `min_price <= recommended_price <= ceiling`

## Run

1. From the repo root:
   - `py tools/ai_price_engine/server.py --port 9010`
2. Set in Laravel `.env`:
   - `AI_PRICE_ENGINE_URL=http://127.0.0.1:9010/recommend`

## Endpoints

- `GET /health` -> `{ "status": "ok" }`
- `GET /v1/weights` -> `{ "weights": { ... } }`
- `POST /recommend` (compat) -> `{ "recommended_price": 123.45, "confidence": 0.83, "model_version": "..." }`
- `POST /v1/recommend` -> same response, with optional `explain`
  - Query: `/v1/recommend?explain=1`
  - Or body flag: `{ "explain": true, ... }`

## Request payload (fields)

**Core inputs**
- `competitor_avg` (number, optional) OR `competitor_prices` (list[number], optional)
- `cost_price` (number, optional if `min_price` provided)
- `desired_margin` (number, 0-1 or percent like `20`)
- `current_price` (number, optional)
- `demand_factor` (number, 0-1 or percent like `50`, optional)
- `min_price` (number, optional; if missing, computed from cost + fees + shipping + margin)

**Optional features (bounded effects)**
- `shipping_cost` (number)
- `platform_fee_pct` (number, 0-1 or percent like `5`)
- `sales_velocity` (number)
- `stock_level` (number)
- `rating` (number, 0-5)
- `promo_factor` (multiplier like `0.9` OR percent discount like `10`)
- `seasonality_factor` (multiplier like `1.05`)

## Response

Always returns:
- `recommended_price`
- `confidence`
- `model_version`

Optionally returns `explain` (when requested) with:
- `min_price`, `ceiling`, `competitor_avg_used`, `demand_effective`
- clamp flags
- alpha/beta/gamma contribution breakdown

## Train weights from real data

The trainer reads CSV/JSON and writes `weights.json` with metrics + metadata:

```bash
py tools/ai_price_engine/train.py --data tools/ai_price_engine/sample_dataset.csv --out tools/ai_price_engine/weights.json
```

**Dataset CSV header template**

```csv
competitor_avg,cost_price,desired_margin,demand_factor,current_price,actual_best_price,shipping_cost,platform_fee_pct,sales_velocity,stock_level,rating,promo_factor,seasonality_factor
```

**JSON format**

```json
[
  {
    "competitor_avg": 199.0,
    "cost_price": 120.0,
    "desired_margin": 20,
    "demand_factor": 0.6,
    "current_price": 189.0,
    "actual_best_price": 195.0
  }
]
```

## Example requests

**Guest browsing (core-only)**

```json
{
  "competitor_avg": 199.0,
  "cost_price": 120.0,
  "desired_margin": 20,
  "current_price": 189.0,
  "demand_factor": 0.6
}
```

**Authenticated / richer signals (+explain)**

```json
{
  "competitor_prices": [199, 205, 198, 240, 201],
  "cost_price": 120.0,
  "shipping_cost": 10.0,
  "platform_fee_pct": 5,
  "desired_margin": 20,
  "current_price": 189.0,
  "demand_factor": 0.6,
  "sales_velocity": 12,
  "stock_level": 30,
  "rating": 4.6,
  "promo_factor": 0.95,
  "seasonality_factor": 1.05,
  "explain": true
}
```

