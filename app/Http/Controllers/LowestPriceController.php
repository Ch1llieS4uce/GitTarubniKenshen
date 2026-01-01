<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use App\Services\MockProductGenerator;

/**
 * AI Lowest Price Recommendation Controller
 * 
 * Groups same products across platforms (Lazada, Shopee, TikTokShop)
 * and recommends the listing with the lowest valid price.
 * 
 * Uses the EXACT fixed product JSON schema.
 */
class LowestPriceController extends Controller
{
    private MockProductGenerator $generator;

    public function __construct()
    {
        $this->generator = new MockProductGenerator();
    }

    /**
     * Get lowest price recommendations grouped by product
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function recommendations(Request $request)
    {
        $limit = min($request->input('limit', 20), 100);
        $offset = max($request->input('offset', 0), 0);
        $category = $request->input('category');
        
        // Cache key based on parameters
        $cacheKey = "lowest_price_recommendations:{$limit}:{$offset}:{$category}";
        
        $result = Cache::remember($cacheKey, 300, function () use ($limit, $offset, $category) {
            return $this->buildRecommendations($limit, $offset, $category);
        });
        
        return response()->json($result);
    }

    /**
     * Get all products with pagination
     */
    public function products(Request $request)
    {
        $platform = $request->input('platform');
        $limit = min($request->input('limit', 50), 200);
        $offset = max($request->input('offset', 0), 0);
        $category = $request->input('category');

        $cacheKey = "products:{$platform}:{$limit}:{$offset}:{$category}";

        $result = Cache::remember($cacheKey, 300, function () use ($platform, $limit, $offset, $category) {
            if ($platform) {
                $products = $this->generator->generateForPlatform($platform, $limit, $offset);
            } else {
                $products = $this->generator->generateAll();
                $products = array_slice($products, $offset, $limit);
            }

            if ($category) {
                $products = array_filter($products, fn($p) => $p['category'] === $category);
                $products = array_values($products);
            }

            return [
                'success' => true,
                'data' => $products,
                'meta' => [
                    'total' => count($products),
                    'limit' => $limit,
                    'offset' => $offset,
                    'platform' => $platform,
                    'category' => $category,
                ],
            ];
        });

        return response()->json($result);
    }

    /**
     * Get a single product by ID
     */
    public function show(Request $request, string $id)
    {
        $allProducts = $this->generator->generateAll();
        
        $product = collect($allProducts)->firstWhere('id', $id);
        
        if (!$product) {
            return response()->json([
                'success' => false,
                'error' => 'Product not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $product,
        ]);
    }

    /**
     * Build recommendations by grouping products and finding lowest prices
     */
    private function buildRecommendations(int $limit, int $offset, ?string $category): array
    {
        // Generate all products
        $allProducts = $this->generator->generateAll();

        if ($category) {
            $allProducts = array_filter($allProducts, fn($p) => $p['category'] === $category);
        }

        // Group by group_id
        $grouped = $this->groupByGroupId($allProducts);

        // Find lowest price winner for each group
        $recommendations = [];
        $processedCount = 0;

        foreach ($grouped as $groupId => $products) {
            if (count($products) < 2) {
                continue; // Need at least 2 platforms for comparison
            }

            if ($processedCount < $offset) {
                $processedCount++;
                continue;
            }

            $recommendation = $this->selectLowestPriceWinner($groupId, $products);
            if ($recommendation) {
                $recommendations[] = $recommendation;
            }

            if (count($recommendations) >= $limit) {
                break;
            }
        }

        // Sort by savings descending (best deals first)
        usort($recommendations, fn($a, $b) => $b['savings'] <=> $a['savings']);

        return [
            'success' => true,
            'data' => $recommendations,
            'meta' => [
                'total' => count($recommendations),
                'limit' => $limit,
                'offset' => $offset,
                'algorithm' => 'lowest_price_winner',
                'platforms' => ['lazada', 'shopee', 'tiktokshop'],
            ],
        ];
    }

    /**
     * Group products by group_id
     */
    private function groupByGroupId(array $products): array
    {
        $groups = [];

        foreach ($products as $product) {
            $groupId = $product['group_id'];
            if (!isset($groups[$groupId])) {
                $groups[$groupId] = [];
            }
            $groups[$groupId][] = $product;
        }

        return $groups;
    }

    /**
     * Select the lowest price winner from a product group
     */
    private function selectLowestPriceWinner(string $groupId, array $products): ?array
    {
        // Build platform price map
        $platformPrices = [];
        $platformProducts = [];

        foreach ($products as $product) {
            $platform = $product['platform'];
            $price = $product['price'] ?? PHP_INT_MAX;

            // Keep the lowest price per platform
            if (!isset($platformPrices[$platform]) || $price < $platformPrices[$platform]) {
                $platformPrices[$platform] = $price;
                $platformProducts[$platform] = $product;
            }
        }

        if (count($platformPrices) < 2) {
            return null;
        }

        // Sort prices to find winner
        asort($platformPrices);
        $sortedPlatforms = array_keys($platformPrices);

        $winnerPlatform = $sortedPlatforms[0];
        $winnerPrice = $platformPrices[$winnerPlatform];
        $winnerProduct = $platformProducts[$winnerPlatform];

        // Calculate savings vs next lowest
        $nextLowestPrice = $platformPrices[$sortedPlatforms[1]] ?? $winnerPrice;
        $savings = round($nextLowestPrice - $winnerPrice, 2);

        // Calculate max price for percentage
        $maxPrice = max($platformPrices);
        $savingsPercent = $maxPrice > 0 ? round((($maxPrice - $winnerPrice) / $maxPrice) * 100, 1) : 0;

        return [
            'group_id' => $groupId,
            'winner' => $winnerProduct,
            'comparison' => [
                'lazada' => $platformPrices['lazada'] ?? null,
                'shopee' => $platformPrices['shopee'] ?? null,
                'tiktokshop' => $platformPrices['tiktokshop'] ?? null,
            ],
            'platform_products' => $platformProducts,
            'savings' => $savings,
            'savings_percent' => $savingsPercent,
            'platforms_compared' => count($platformPrices),
            'recommendation_reason' => $this->buildReason($winnerPlatform, $savings, $savingsPercent),
        ];
    }

    /**
     * Build human-readable recommendation reason
     */
    private function buildReason(string $platform, float $savings, float $savingsPercent): string
    {
        $platformName = match ($platform) {
            'lazada' => 'Lazada',
            'shopee' => 'Shopee',
            'tiktokshop' => 'TikTok Shop',
            default => ucfirst($platform),
        };

        if ($savings > 0) {
            return "{$platformName} offers the lowest price, saving you ₱" . number_format($savings, 2) .
                   " (" . number_format($savingsPercent, 0) . "% less than other platforms)";
        }

        return "{$platformName} offers the best available price for this product";
    }
}
