<?php

namespace App\Services\Pricing;

use App\Models\Listing;
use Illuminate\Support\Facades\Http;

class PriceRecommendationEngine
{
    public function __construct(private readonly MarketSignalsService $marketSignalsService)
    {
    }

    public function recommendForListing(Listing $listing): array
    {
        $product = $listing->product;

        $costPrice = (float)($product?->cost_price ?? 0);
        $desiredMargin = (float)($product?->desired_margin ?? 0);
        if ($desiredMargin > 1) {
            $desiredMargin = $desiredMargin / 100;
        }

        $minPrice = $costPrice * (1 + max(0, $desiredMargin));
        $currentPrice = (float)($listing->price ?? 0);

        $signals = $this->marketSignalsService->signalsForListing($listing);
        $competitorAvg = is_numeric($signals['competitor_avg'] ?? null) ? (float)$signals['competitor_avg'] : null;
        $demandFactor = is_numeric($signals['demand_factor'] ?? null) ? (float)$signals['demand_factor'] : 0.5;
        $sampleSize = (int)($signals['sample_size'] ?? 0);

        if ($competitorAvg === null) {
            $competitorAvg = $listing->priceHistory()
                ->where('source', 'competitor')
                ->latest('recorded_at')
                ->take(20)
                ->pluck('price')
                ->map(fn ($p) => (float)$p)
                ->avg();
        }

        $aiUrl = config('pricing.ai_price_engine_url');
        if (is_string($aiUrl) && $aiUrl !== '') {
            $payload = [
                'listing_id' => (int)$listing->id,
                'product_id' => (int)($product?->id ?? 0),
                'title' => $product?->title,
                'cost_price' => $costPrice,
                'desired_margin' => $desiredMargin,
                'current_price' => $currentPrice,
                'competitor_avg' => $competitorAvg,
                'demand_factor' => $demandFactor,
                'min_price' => $minPrice,
                'market_sample_size' => $sampleSize,
                'market_source' => (string)($signals['source'] ?? 'unknown'),
            ];

            try {
                $res = Http::timeout(3)->post($aiUrl, $payload);
                if ($res->successful()) {
                    $json = $res->json();
                    $recommended = $json['recommended_price'] ?? $json['price'] ?? null;
                    if (is_numeric($recommended)) {
                        $confidence = $json['confidence'] ?? null;
                        $conf = is_numeric($confidence) ? (float)$confidence : 0.7;
                        if ($conf > 1) {
                            $conf = $conf / 100;
                        }

                        $bounded = $this->applyConstraints(
                            (float)$recommended,
                            $minPrice,
                            is_numeric($competitorAvg) ? (float)$competitorAvg : null
                        );

                        return [
                            'recommended_price' => round($bounded, 2),
                            'confidence' => max(0, min(1, $conf)),
                            'model_version' => (string)($json['model_version'] ?? 'remote'),
                        ];
                    }
                }
            } catch (\Throwable) {
                // fall back to heuristic
            }
        }

        $recommended = $this->formulaRecommend(
            $competitorAvg,
            $minPrice,
            $demandFactor,
            $currentPrice
        );

        $recommended = round($this->applyConstraints($recommended, $minPrice, $competitorAvg), 2);
        $confidence = min(1, max(0, 0.5 + ($competitorAvg !== null ? 0.2 : 0) + ($sampleSize > 0 ? 0.15 : 0)));

        return [
            'recommended_price' => $recommended,
            'confidence' => $confidence,
            'model_version' => 'formula-v1',
        ];
    }

    private function formulaRecommend(?float $competitorAvg, float $minPrice, float $demandFactor, float $currentPrice): float
    {
        $alpha = (float) config('pricing.alpha', 0.65);
        $beta = (float) config('pricing.beta', 0.35);
        $gammaMultiplier = (float) config('pricing.gamma_multiplier', 0.05);

        $demand = max(0.0, min(1.0, $demandFactor));

        if ($competitorAvg === null || $competitorAvg <= 0) {
            $base = $currentPrice > 0 ? $currentPrice : $minPrice;
            return max($minPrice, $base);
        }

        $gamma = $gammaMultiplier * $competitorAvg;
        return ($alpha * $competitorAvg) + ($beta * $minPrice) + ($gamma * $demand);
    }

    private function applyConstraints(float $candidate, float $minPrice, ?float $competitorAvg): float
    {
        $floor = $minPrice;

        if ($competitorAvg === null || $competitorAvg <= 0) {
            return max($candidate, $floor);
        }

        $ceilingPct = (float) config('pricing.competitive_ceiling_pct', 0.05);
        $ceiling = max($floor, $competitorAvg * (1 + max(0, $ceilingPct)));

        return min(max($candidate, $floor), $ceiling);
    }
}
