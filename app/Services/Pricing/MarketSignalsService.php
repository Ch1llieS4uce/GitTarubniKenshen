<?php

namespace App\Services\Pricing;

use App\Models\Listing;
use App\Models\PriceHistory;
use App\Services\Affiliates\AffiliateClientFactory;
use Illuminate\Support\Facades\Cache;

class MarketSignalsService
{
    private const CACHE_TTL_MINUTES = 30;
    private const SEARCH_PAGE_SIZE = 20;
    private const DEMAND_SALES_SCALE = 50000.0;

    public function __construct(private readonly AffiliateClientFactory $affiliateClientFactory)
    {
    }

    /**
     * @return array{competitor_avg: float|null, demand_factor: float, avg_sales: float|null, sample_size: int, source: string}
     */
    public function signalsForListing(Listing $listing): array
    {
        $product = $listing->product;
        $query = trim((string)($product?->title ?? $product?->sku ?? $listing->platform_product_id ?? ''));

        $cacheKey = 'market_signals:v1:' . md5(mb_strtolower($query));
        $cached = Cache::get($cacheKey);
        if (is_array($cached)) {
            return $cached;
        }

        $prices = [];
        $sales = [];

        foreach (['shopee', 'lazada', 'tiktok'] as $platform) {
            try {
                $client = $this->affiliateClientFactory->make($platform);
                $results = $client->search($query, 1, self::SEARCH_PAGE_SIZE);

                if (!is_array($results)) {
                    continue;
                }

                foreach ($results as $item) {
                    if (!is_array($item)) {
                        continue;
                    }

                    $price = $item['price'] ?? null;
                    if (is_numeric($price) && (float)$price > 0) {
                        $prices[] = (float)$price;
                    }

                    $saleCount = $item['sales'] ?? null;
                    if (is_numeric($saleCount) && (float)$saleCount >= 0) {
                        $sales[] = (float)$saleCount;
                    }
                }
            } catch (\Throwable) {
                // ignore platform errors; we use mocks today and can tolerate failures
            }
        }

        $competitorAvg = $this->trimmedMean($prices);
        $avgSales = $this->trimmedMean($sales);

        $demandFactor = $avgSales === null ? 0.5 : $this->salesToDemandFactor($avgSales);

        if ($competitorAvg !== null) {
            PriceHistory::create([
                'listing_id' => $listing->id,
                'price' => round($competitorAvg, 2),
                'source' => 'competitor',
                'recorded_at' => now(),
            ]);
        }

        $signals = [
            'competitor_avg' => $competitorAvg === null ? null : round($competitorAvg, 2),
            'demand_factor' => round($demandFactor, 4),
            'avg_sales' => $avgSales === null ? null : round($avgSales, 2),
            'sample_size' => count($prices),
            'source' => 'mock_marketplace_clients',
        ];

        Cache::put($cacheKey, $signals, now()->addMinutes(self::CACHE_TTL_MINUTES));

        return $signals;
    }

    private function salesToDemandFactor(float $avgSales): float
    {
        if ($avgSales <= 0) {
            return 0.0;
        }

        $df = 1 - exp(-$avgSales / self::DEMAND_SALES_SCALE);
        return max(0.0, min(1.0, $df));
    }

    /**
     * @param array<int, float> $values
     */
    private function trimmedMean(array $values): ?float
    {
        $count = count($values);
        if ($count === 0) {
            return null;
        }

        sort($values);

        $trim = $count >= 10 ? (int)floor($count * 0.1) : 0;
        $slice = array_slice($values, $trim, $count - ($trim * 2));

        if (count($slice) === 0) {
            return null;
        }

        return array_sum($slice) / count($slice);
    }
}

