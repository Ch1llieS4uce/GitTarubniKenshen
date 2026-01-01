"""
Optional: PyTorch training stub for the slide formula.

This file is intentionally not used by default because this repo's dev container
does not ship with torch. When you're ready, install torch locally and run:

  py tools/ai_price_engine/train_pytorch.py

It will print learned alpha/beta/gamma coefficients you can copy into weights.json.
"""

from __future__ import annotations

import random

try:
    import torch
    import torch.nn as nn
except ModuleNotFoundError as e:  # pragma: no cover
    raise SystemExit("PyTorch not installed. Install torch to use this script.") from e


def make_synthetic_dataset(n: int = 2000):
    # Synthetic "market" examples
    xs = []
    ys = []

    # Ground-truth parameters used to generate targets.
    alpha_true = 0.62
    beta_true = 0.38
    gamma_mult_true = 0.06

    for _ in range(n):
        competitor_avg = random.uniform(80, 15000)
        min_price = random.uniform(60, competitor_avg * 1.2)
        demand_factor = random.uniform(0, 1)

        gamma = gamma_mult_true * competitor_avg
        y = (alpha_true * competitor_avg) + (beta_true * min_price) + (gamma * demand_factor)
        y += random.gauss(0, competitor_avg * 0.01)  # noise

        xs.append([competitor_avg, min_price, demand_factor])
        ys.append([y])

    return torch.tensor(xs, dtype=torch.float32), torch.tensor(ys, dtype=torch.float32)


def main():
    x, y = make_synthetic_dataset()

    model = nn.Linear(3, 1)
    opt = torch.optim.Adam(model.parameters(), lr=0.05)
    loss_fn = nn.MSELoss()

    for _ in range(200):
        opt.zero_grad()
        pred = model(x)
        loss = loss_fn(pred, y)
        loss.backward()
        opt.step()

    w = model.weight.detach().cpu().numpy().tolist()[0]
    b = model.bias.detach().cpu().numpy().tolist()[0]

    print("Learned weights:")
    print(f"  alpha (Pc): {w[0]:.4f}")
    print(f"  beta  (min_price): {w[1]:.4f}")
    print(f"  gamma (Df): {w[2]:.4f}")
    print(f"  bias: {b:.4f}")


if __name__ == "__main__":
    main()

