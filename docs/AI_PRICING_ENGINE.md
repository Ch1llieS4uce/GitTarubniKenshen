# AI Pricing Recommendation Engine (Explainable v2)

## Goal

Recommend a selling price that is:
- **Profitable** (never below a computed break-even floor)
- **Competitive** (anchored to market prices)
- **Responsive** (bounded demand/stock adjustments)
- **Safe** (hard clamps + weight constraints)
- **Explainable** (returns a component breakdown when requested)

This engine is designed for mobile usage (fast, predictable JSON) and thesis/panel defense (simple math, clear rules).

## Core formula (v2)

Inputs:
- `Pc`: competitor average price (`competitor_avg` or robust average of `competitor_prices`)
- `Cp`: cost price (`cost_price`)
- `Mt`: desired margin (`desired_margin`, accepts `0.2` or `20`)
- `Df`: demand factor (`demand_factor`, 0..1, optional)

Min price floor includes fees and shipping:

`min_price = ((Cp + shipping_cost) / (1 - platform_fee_pct)) * (1 + Mt)`

Candidate price (before clamping):

`candidate = alpha * Pc + beta * min_price + gamma_multiplier * (Pc * demand_effective)`

Final safety clamp:

`recommended_price = clamp(candidate, min_price, ceiling)`

Where:
- `ceiling = max(min_price, Pc * (1 + competitive_ceiling_pct))`
- `alpha` and `beta` are constrained to be non‑negative and sum to ~1

## Optional feature adjustments (bounded)

These features are optional and only influence the score when present:
- `sales_velocity` and `rating` adjust `demand_effective` slightly (clamped to 0..1)
- `stock_level` applies a small multiplier (default ±8%) to avoid overpricing when inventory is high
- `promo_factor` and `seasonality_factor` apply bounded multipliers (e.g., promo discount, seasonal uplift)

## Explain output

`POST /v1/recommend?explain=1` (or `{"explain": true}`) returns an `explain` object with:
- `min_price`, `ceiling`, `competitor_avg_used`, `demand_effective`
- which clamps fired
- contribution breakdown: alpha/beta/gamma components
- applied multipliers and smoothing

## Training (real data, interpretable)

Script: `tools/ai_price_engine/train.py`

Dataset rows contain:
- `competitor_avg`, `cost_price`, `desired_margin`, `demand_factor`, `current_price`
- label: `actual_best_price`
- optional extra features

Training:
- Cleans invalid rows
- Fits a simple **ridge regression** (interpretable linear model)
- Maps learned coefficients into:
  - `alpha`, `beta`, `gamma_multiplier`
  - `competitive_ceiling_pct` tuned from observed price/competitor ratios
  - `demand_default` from the median demand factor
- Writes a new `weights.json` with metrics (MAE/RMSE/MAPE) and a bumped `model_version`

## Deployment integration

Run:
- `py tools/ai_price_engine/server.py --port 9010`

Laravel config:
- `AI_PRICE_ENGINE_URL=http://127.0.0.1:9010/recommend`

The Laravel API continues to expose the mobile endpoint:
- `GET /api/listings/{id}/recommendation`

