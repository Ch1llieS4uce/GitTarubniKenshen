"""
Compatibility wrapper.

This project started with a PyTorch-only synthetic training stub. For a production/demo-ready
workflow (real CSV/JSON datasets, metrics, and weights.json export) use:

  py tools/ai_price_engine/train.py --data <dataset.csv>

This file remains so older docs/commands still work:

  py tools/ai_price_engine/train_pytorch.py --data <dataset.csv>
"""

from __future__ import annotations

from train import main


if __name__ == "__main__":
    main()
