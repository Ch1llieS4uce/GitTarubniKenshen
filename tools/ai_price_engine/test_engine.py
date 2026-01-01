from __future__ import annotations

import os
import sys
import unittest

THIS_DIR = os.path.dirname(__file__)
if THIS_DIR not in sys.path:
    sys.path.insert(0, THIS_DIR)

import server  # noqa: E402


class PriceEngineTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.weights = server._load_weights(os.path.join(os.path.dirname(__file__), "weights.json"))

    def test_recommend_respects_min_and_ceiling(self) -> None:
        payload = {
            "competitor_avg": 200.0,
            "cost_price": 120.0,
            "shipping_cost": 10.0,
            "platform_fee_pct": 0.05,
            "desired_margin": 0.2,
            "demand_factor": 0.6,
            "current_price": 190.0,
            "explain": True,
        }

        res = server.recommend(payload, self.weights, explain=True)
        self.assertIn("recommended_price", res)
        self.assertIn("confidence", res)
        self.assertIn("model_version", res)
        self.assertIn("explain", res)

        explain = res["explain"]
        self.assertGreaterEqual(res["recommended_price"], explain["min_price"])
        self.assertLessEqual(res["recommended_price"], explain["ceiling"])

    def test_competitor_prices_uses_robust_aggregator(self) -> None:
        payload = {
            "competitor_prices": [199, 205, 198, 240, 9999],  # outlier should be trimmed
            "cost_price": 120.0,
            "desired_margin": 0.2,
            "demand_factor": 0.5,
            "current_price": 190.0,
            "explain": True,
        }

        res = server.recommend(payload, self.weights, explain=True)
        explain = res["explain"]
        self.assertEqual(explain["competitor_method"], "trimmed_mean_10pct")
        self.assertLess(explain["competitor_avg_used"], 1000)

    def test_missing_competitor_falls_back_to_current_or_min(self) -> None:
        payload = {
            "cost_price": 100.0,
            "desired_margin": 0.2,
            "current_price": 150.0,
            "explain": True,
        }

        res = server.recommend(payload, self.weights, explain=True)
        explain = res["explain"]
        self.assertIsNone(explain["competitor_avg_used"])
        self.assertGreaterEqual(res["recommended_price"], explain["min_price"])

    def test_invalid_min_price_errors(self) -> None:
        payload = {
            "competitor_avg": 200.0,
            "min_price": 0,
            "desired_margin": 0.2,
        }
        with self.assertRaises(server.InputError):
            server.recommend(payload, self.weights)


if __name__ == "__main__":
    unittest.main()
