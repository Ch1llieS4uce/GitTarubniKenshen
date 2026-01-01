# AI Price Engine (Mock)

This is a small local HTTP service that Laravel can call via `AI_PRICE_ENGINE_URL`.

It implements the paper/formula in the slide:

`Pr = α(Pc) + β(Cp * (1 + Mt)) + γ(Df)`

Where:
- `Pc` = competitor average price
- `Cp` = product cost
- `Mt` = target margin (0-1)
- `Df` = demand factor (0-1)

## Run

1. From the repo root:
   - `py tools/ai_price_engine/server.py --port 9010`
2. Set in Laravel `.env`:
   - `AI_PRICE_ENGINE_URL=http://127.0.0.1:9010/recommend`

## Endpoints

- `GET /health` -> `{ "status": "ok" }`
- `POST /recommend` -> `{ "recommended_price": 123.45, "confidence": 0.83, "model_version": "..." }`

## Notes

- This server uses only Python's standard library.
- If you later install PyTorch, you can extend this to load a real `torch` model; see `train_pytorch.py`.

