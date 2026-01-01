<?php

namespace App\Http\Controllers;

use App\Http\Resources\AffiliateProductResource;
use App\Services\Affiliates\AffiliateProductService;
use App\Services\AuditLogger;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class AffiliateProductController extends Controller
{
    public function __construct(
        protected AffiliateProductService $productService,
        protected AuditLogger $auditLogger
    ) {}

    /**
     * List/search affiliate products with pagination.
     * 
     * GET /api/affiliate-products
     * 
     * Query params:
     * - platform: lazada|shopee|tiktok|all (default: all)
     * - query: search term (optional)
     * - page: page number (default: 1)
     * - limit: items per page (default: 50, max: 200)
     * - min_price: minimum price filter (optional)
     * - max_price: maximum price filter (optional)
     * - min_rating: minimum rating filter (optional)
     * - sort: relevance|price_asc|price_desc|rating|sales|newest (default: relevance)
     */
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'platform' => 'nullable|in:lazada,shopee,tiktok,all',
            'query' => 'nullable|string|max:255',
            'page' => 'nullable|integer|min:1',
            'limit' => 'nullable|integer|min:1|max:200',
            'min_price' => 'nullable|numeric|min:0',
            'max_price' => 'nullable|numeric|min:0',
            'min_rating' => 'nullable|numeric|min:0|max:5',
            'sort' => 'nullable|in:relevance,price_asc,price_desc,rating,sales,newest',
        ]);

        $platform = $validated['platform'] ?? 'all';
        $query = $validated['query'] ?? null;
        $page = (int) ($validated['page'] ?? 1);
        $limit = (int) ($validated['limit'] ?? 50);
        $filters = [
            'min_price' => $validated['min_price'] ?? null,
            'max_price' => $validated['max_price'] ?? null,
            'min_rating' => $validated['min_rating'] ?? null,
            'sort' => $validated['sort'] ?? 'relevance',
        ];

        try {
            if ($platform === 'all') {
                $paginator = $this->productService->searchAllPlatforms($query, $page, $limit, $filters);
            } else {
                $paginator = $this->productService->search($platform, $query, $page, $limit, $filters);
            }

            // Log the search (non-blocking)
            try {
                $this->auditLogger->log(
                    optional($request->user())->id,
                    'affiliate_product_search',
                    [
                        'platform' => $platform,
                        'query' => $query,
                        'page' => $page,
                        'limit' => $limit,
                        'filters' => $filters,
                        'result_count' => $paginator->count(),
                        'total_count' => $paginator->total(),
                    ]
                );
            } catch (\Throwable) {
                // Don't block on audit failures
            }

            return response()->json([
                'success' => true,
                'data' => AffiliateProductResource::collection($paginator->items()),
                'meta' => [
                    'current_page' => $paginator->currentPage(),
                    'per_page' => $paginator->perPage(),
                    'total' => $paginator->total(),
                    'last_page' => $paginator->lastPage(),
                    'has_more' => $paginator->hasMorePages(),
                ],
            ]);
        } catch (\Throwable $e) {
            Log::error('Affiliate product search failed', [
                'platform' => $platform,
                'query' => $query,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch products. Please try again.',
                'data' => [],
                'meta' => [
                    'current_page' => $page,
                    'per_page' => $limit,
                    'total' => 0,
                    'last_page' => 1,
                    'has_more' => false,
                ],
            ], 500);
        }
    }

    /**
     * Get a single product by platform and ID.
     * 
     * GET /api/affiliate-products/{platform}/{id}
     */
    public function show(Request $request, string $platform, string $id): JsonResponse
    {
        if (!in_array($platform, ['lazada', 'shopee', 'tiktok'])) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid platform',
            ], 400);
        }

        try {
            // Try cache first
            $cached = \App\Models\CachedAffiliateProduct::query()
                ->where('platform', $platform)
                ->where('platform_product_id', $id)
                ->first();

            if ($cached) {
                return response()->json([
                    'success' => true,
                    'data' => AffiliateProductResource::make($cached->toNormalizedArray()),
                ]);
            }

            // Fall back to live API
            $client = app(\App\Services\Affiliates\AffiliateClientFactory::class)->make($platform);
            $product = $client->getProduct($id);

            if (empty($product)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Product not found',
                ], 404);
            }

            $product['platform'] = $platform;
            $product['data_source'] = sprintf('Data provided via %s Affiliate API', ucfirst($platform));

            return response()->json([
                'success' => true,
                'data' => AffiliateProductResource::make($product),
            ]);
        } catch (\Throwable $e) {
            Log::error('Failed to fetch product', [
                'platform' => $platform,
                'id' => $id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch product',
            ], 500);
        }
    }

    /**
     * Get platform statistics.
     * 
     * GET /api/affiliate-products/stats
     */
    public function stats(): JsonResponse
    {
        try {
            $stats = $this->productService->getPlatformStats();

            return response()->json([
                'success' => true,
                'data' => $stats,
            ]);
        } catch (\Throwable $e) {
            Log::error('Failed to fetch platform stats', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch statistics',
            ], 500);
        }
    }
}
