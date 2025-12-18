<?php

namespace App\Services\Pricing;

use App\Models\Listing;
use Illuminate\Support\Facades\Http;

class PriceRecommendationEngine
{
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

        $competitorAvg = $listing->priceHistory()
            ->where('source', 'competitor')
            ->latest('recorded_at')
            ->take(20)
            ->pluck('price')
            ->map(fn ($p) => (float)$p)
            ->avg();

        $aiUrl = env('AI_PRICE_ENGINE_URL');
        if (is_string($aiUrl) && $aiUrl !== '') {
            $payload = [
                'title' => $product?->title,
                'cost_price' => $costPrice,
                'desired_margin' => $desiredMargin,
                'current_price' => $currentPrice,
                'competitor_avg' => $competitorAvg,
                'min_price' => $minPrice,
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

                        return [
                            'recommended_price' => round((float)$recommended, 2),
                            'confidence' => max(0, min(1, $conf)),
                            'model_version' => (string)($json['model_version'] ?? 'remote'),
                        ];
                    }
                }
            } catch (\Throwable) {
                // fall back to heuristic
            }
        }

        $candidate = $currentPrice > 0 ? $currentPrice : $minPrice;

        if ($competitorAvg !== null) {
            $candidate = min($competitorAvg * 0.99, max($candidate, $minPrice));
        } else {
            $candidate = max($candidate, $minPrice);
        }

        $recommended = round($candidate, 2);
        $confidence = $competitorAvg !== null ? 0.75 : 0.55;

        return [
            'recommended_price' => $recommended,
            'confidence' => $confidence,
            'model_version' => 'heuristic-v1',
        ];
    }
}
