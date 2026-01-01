<?php

namespace App\Services\Affiliates;

use App\Models\CachedAffiliateProduct;
use App\Services\Affiliates\Contracts\ProductSearchClient;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

class AffiliateProductService
{
    protected const CACHE_TTL_MINUTES = 60;
    protected const MAX_PRODUCTS_PER_PLATFORM = 2000;
    protected const BATCH_SIZE = 200;
    protected const PLATFORMS = ['lazada', 'shopee', 'tiktok'];

    public function __construct(
        protected AffiliateClientFactory $clientFactory
    ) {}

    /**
     * Search products with pagination support.
     * Uses cached products if available, falls back to live API.
     *
     * @param string $platform
     * @param string|null $query
     * @param int $page
     * @param int $perPage
     * @param array $filters ['min_price' => float, 'max_price' => float, 'min_rating' => float, 'sort' => string]
     * @return LengthAwarePaginator
     */
    public function search(
        string $platform,
        ?string $query = null,
        int $page = 1,
        int $perPage = 50,
        array $filters = []
    ): LengthAwarePaginator {
        $perPage = min($perPage, 200); // Max 200 per request

        // Try cached products first
        if ($this->hasCachedProducts($platform)) {
            return $this->searchCached($platform, $query, $page, $perPage, $filters);
        }

        // Fall back to live API with caching
        return $this->searchLive($platform, $query, $page, $perPage, $filters);
    }

    /**
     * Get products from all platforms (aggregated).
     */
    public function searchAllPlatforms(
        ?string $query = null,
        int $page = 1,
        int $perPage = 50,
        array $filters = []
    ): LengthAwarePaginator {
        $allProducts = collect();
        $errors = [];

        foreach (self::PLATFORMS as $platform) {
            try {
                $result = $this->search($platform, $query, 1, self::MAX_PRODUCTS_PER_PLATFORM, $filters);
                $allProducts = $allProducts->merge($result->items());
            } catch (\Throwable $e) {
                Log::warning("Failed to fetch products from {$platform}", [
                    'error' => $e->getMessage(),
                ]);
                $errors[$platform] = $e->getMessage();
            }
        }

        // Deduplicate by platform_product_id
        $allProducts = $allProducts->unique(fn($p) => $p['platform'] . '-' . ($p['platform_product_id'] ?? $p['id']));

        // Apply sorting
        $allProducts = $this->applySorting($allProducts, $filters['sort'] ?? 'relevance');

        // Paginate
        $offset = ($page - 1) * $perPage;
        $items = $allProducts->slice($offset, $perPage)->values();

        return new LengthAwarePaginator(
            $items,
            $allProducts->count(),
            $perPage,
            $page,
            ['path' => request()->url(), 'query' => request()->query()]
        );
    }

    /**
     * Search from cached database products.
     */
    protected function searchCached(
        string $platform,
        ?string $query,
        int $page,
        int $perPage,
        array $filters
    ): LengthAwarePaginator {
        $builder = CachedAffiliateProduct::query()
            ->platform($platform)
            ->search($query)
            ->priceRange($filters['min_price'] ?? null, $filters['max_price'] ?? null)
            ->minRating($filters['min_rating'] ?? null);

        // Apply sorting
        $sort = $filters['sort'] ?? 'relevance';
        $builder = match ($sort) {
            'price_asc' => $builder->orderBy('price', 'asc'),
            'price_desc' => $builder->orderBy('price', 'desc'),
            'rating' => $builder->orderBy('rating', 'desc'),
            'sales' => $builder->orderBy('sales', 'desc'),
            'newest' => $builder->orderBy('synced_at', 'desc'),
            default => $builder->orderBy('sales', 'desc'), // relevance = sales
        };

        $paginated = $builder->paginate($perPage, ['*'], 'page', $page);

        // Transform to normalized array format
        $items = $paginated->getCollection()->map(fn($p) => $p->toNormalizedArray());

        return new LengthAwarePaginator(
            $items,
            $paginated->total(),
            $perPage,
            $page,
            ['path' => request()->url(), 'query' => request()->query()]
        );
    }

    /**
     * Search from live API with result caching.
     */
    protected function searchLive(
        string $platform,
        ?string $query,
        int $page,
        int $perPage,
        array $filters
    ): LengthAwarePaginator {
        $cacheKey = sprintf('affiliate_search:%s:%s:%d:%d', $platform, md5($query ?? ''), $page, $perPage);

        $results = Cache::remember($cacheKey, now()->addMinutes(self::CACHE_TTL_MINUTES), function () use ($platform, $query, $page, $perPage) {
            try {
                $client = $this->clientFactory->make($platform);
                return $client->search($query ?? '', $page, $perPage);
            } catch (\Throwable $e) {
                Log::error("Affiliate API error for {$platform}", [
                    'query' => $query,
                    'error' => $e->getMessage(),
                ]);
                throw $e;
            }
        });

        if (!is_array($results)) {
            $results = [];
        }

        // Normalize and add platform
        $normalized = array_map(function ($item) use ($platform) {
            $item['platform'] = $platform;
            $item['platform_product_id'] = $item['id'] ?? $item['platform_product_id'] ?? null;
            $item['data_source'] = sprintf('Data provided via %s Affiliate API', ucfirst($platform));
            return $item;
        }, $results);

        // Apply filters
        $collection = collect($normalized);
        
        if (!empty($filters['min_price'])) {
            $collection = $collection->where('price', '>=', $filters['min_price']);
        }
        if (!empty($filters['max_price'])) {
            $collection = $collection->where('price', '<=', $filters['max_price']);
        }
        if (!empty($filters['min_rating'])) {
            $collection = $collection->where('rating', '>=', $filters['min_rating']);
        }

        $collection = $this->applySorting($collection, $filters['sort'] ?? 'relevance');

        // We don't know total from live API, estimate based on page size
        $total = max(count($results), $page * $perPage);

        return new LengthAwarePaginator(
            $collection->values(),
            $total,
            $perPage,
            $page,
            ['path' => request()->url(), 'query' => request()->query()]
        );
    }

    /**
     * Check if we have cached products for a platform.
     */
    protected function hasCachedProducts(string $platform): bool
    {
        return Cache::remember(
            "has_cached_products:{$platform}",
            now()->addMinutes(5),
            fn() => CachedAffiliateProduct::platform($platform)->exists()
        );
    }

    /**
     * Sync products from affiliate API to database cache.
     * This should be called from a background job.
     *
     * @param string $platform
     * @param int $maxProducts
     * @return array Stats about the sync
     */
    public function syncPlatformProducts(string $platform, int $maxProducts = 2000): array
    {
        $client = $this->clientFactory->make($platform);
        $synced = 0;
        $failed = 0;
        $page = 1;

        Log::info("Starting product sync for {$platform}", ['max' => $maxProducts]);

        while ($synced < $maxProducts) {
            try {
                $batchSize = min(self::BATCH_SIZE, $maxProducts - $synced);
                $results = $client->search('', $page, $batchSize);

                if (empty($results)) {
                    Log::info("No more products from {$platform} at page {$page}");
                    break;
                }

                foreach ($results as $product) {
                    try {
                        CachedAffiliateProduct::upsertFromNormalized($platform, $product);
                        $synced++;
                    } catch (\Throwable $e) {
                        $failed++;
                        Log::warning("Failed to sync product", [
                            'platform' => $platform,
                            'product_id' => $product['id'] ?? 'unknown',
                            'error' => $e->getMessage(),
                        ]);
                    }
                }

                if (count($results) < $batchSize) {
                    break; // No more products
                }

                $page++;
            } catch (\Throwable $e) {
                Log::error("Batch sync failed for {$platform}", [
                    'page' => $page,
                    'error' => $e->getMessage(),
                ]);
                break;
            }
        }

        // Clear cache flags
        Cache::forget("has_cached_products:{$platform}");

        $stats = [
            'platform' => $platform,
            'synced' => $synced,
            'failed' => $failed,
            'pages_processed' => $page,
        ];

        Log::info("Product sync completed for {$platform}", $stats);

        return $stats;
    }

    /**
     * Sync all platforms.
     */
    public function syncAllPlatforms(int $maxPerPlatform = 2000): array
    {
        $results = [];
        foreach (self::PLATFORMS as $platform) {
            $results[$platform] = $this->syncPlatformProducts($platform, $maxPerPlatform);
        }
        return $results;
    }

    /**
     * Get platform statistics.
     */
    public function getPlatformStats(): array
    {
        $stats = [];
        foreach (self::PLATFORMS as $platform) {
            $stats[$platform] = [
                'cached_count' => CachedAffiliateProduct::platform($platform)->count(),
                'last_sync' => CachedAffiliateProduct::platform($platform)->max('synced_at'),
            ];
        }
        return $stats;
    }

    /**
     * Apply sorting to a collection.
     */
    protected function applySorting(Collection $collection, string $sort): Collection
    {
        return match ($sort) {
            'price_asc' => $collection->sortBy('price'),
            'price_desc' => $collection->sortByDesc('price'),
            'rating' => $collection->sortByDesc('rating'),
            'sales' => $collection->sortByDesc('sales'),
            'newest' => $collection->sortByDesc('synced_at'),
            default => $collection->sortByDesc('sales'), // relevance = sales
        };
    }
}
