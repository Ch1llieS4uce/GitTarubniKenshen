<?php

namespace App\Http\Controllers;

use App\Models\CachedAffiliateProduct;
use App\Services\DynamicPricingSimulator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Live Pricing Controller
 * 
 * Provides real-time price updates via:
 * - Server-Sent Events (SSE) for streaming
 * - Polling fallback with delta updates
 * 
 * For thesis demonstration of dynamic pricing simulation.
 */
class LivePricingController extends Controller
{
    private const SSE_RETRY_MS = 3000;
    private const TICK_INTERVAL_SECONDS = 3;
    private const MAX_SSE_DURATION_SECONDS = 300; // 5 minutes max

    public function __construct(
        private DynamicPricingSimulator $simulator
    ) {}

    /**
     * SSE endpoint for real-time price updates
     * 
     * GET /api/live-pricing/stream
     * 
     * Query params:
     * - platforms: comma-separated (lazada,shopee,tiktok)
     * - limit: max products per tick (default: 50)
     * - demo_mode: use fixed seed for panel demo stability
     */
    public function stream(Request $request): StreamedResponse
    {
        $platforms = $request->query('platforms', 'lazada,shopee,tiktok');
        $platforms = array_filter(explode(',', $platforms));
        $limit = min(100, max(10, (int) $request->query('limit', 50)));
        $demoMode = filter_var($request->query('demo_mode', false), FILTER_VALIDATE_BOOLEAN);

        if ($demoMode) {
            $this->simulator->setFixedSeed(42);
        }

        return response()->stream(function () use ($platforms, $limit) {
            $startTime = time();
            $lastTick = 0;

            // Send initial connection event
            $this->sendSSEEvent('connected', [
                'message' => 'Live pricing stream connected',
                'interval_ms' => self::TICK_INTERVAL_SECONDS * 1000,
                'timestamp' => now()->toIso8601String(),
            ]);

            while (true) {
                // Check timeout
                if ((time() - $startTime) > self::MAX_SSE_DURATION_SECONDS) {
                    $this->sendSSEEvent('timeout', [
                        'message' => 'Stream timeout, please reconnect',
                    ]);
                    break;
                }

                // Check if connection is still alive
                if (connection_aborted()) {
                    break;
                }

                $currentTick = $this->simulator->getCurrentTick();

                // Only emit on new tick
                if ($currentTick > $lastTick) {
                    $lastTick = $currentTick;

                    // Get products to update
                    $products = $this->getProductsForUpdate($platforms, $limit);
                    
                    // Simulate price updates
                    $updates = $this->simulator->simulateTick($products);

                    if (!empty($updates)) {
                        $this->sendSSEEvent('price_update', [
                            'tick' => $currentTick,
                            'count' => count($updates),
                            'products' => $updates,
                            'timestamp' => now()->toIso8601String(),
                        ]);
                    }

                    // Send heartbeat
                    $this->sendSSEEvent('heartbeat', [
                        'tick' => $currentTick,
                        'timestamp' => now()->toIso8601String(),
                    ]);
                }

                // Flush output
                if (ob_get_level() > 0) {
                    ob_flush();
                }
                flush();

                // Sleep until next check (100ms intervals)
                usleep(100000);
            }
        }, 200, [
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'Connection' => 'keep-alive',
            'X-Accel-Buffering' => 'no', // Disable nginx buffering
        ]);
    }

    /**
     * Polling fallback endpoint for delta updates
     * 
     * GET /api/live-pricing/poll
     * 
     * Query params:
     * - since_tick: last received tick (for delta)
     * - platforms: comma-separated
     * - limit: max products
     */
    public function poll(Request $request): JsonResponse
    {
        $sinceTick = (int) $request->query('since_tick', 0);
        $platforms = $request->query('platforms', 'lazada,shopee,tiktok');
        $platforms = array_filter(explode(',', $platforms));
        $limit = min(100, max(10, (int) $request->query('limit', 50)));

        $currentTick = $this->simulator->getCurrentTick();

        // Return early if no new tick
        if ($currentTick <= $sinceTick) {
            return response()->json([
                'success' => true,
                'tick' => $currentTick,
                'has_updates' => false,
                'products' => [],
                'timestamp' => now()->toIso8601String(),
            ]);
        }

        // Get and update products
        $products = $this->getProductsForUpdate($platforms, $limit);
        $updates = $this->simulator->simulateTick($products);

        return response()->json([
            'success' => true,
            'tick' => $currentTick,
            'has_updates' => !empty($updates),
            'count' => count($updates),
            'products' => $updates,
            'timestamp' => now()->toIso8601String(),
            'next_poll_ms' => self::TICK_INTERVAL_SECONDS * 1000,
        ]);
    }

    /**
     * Get pricing explanation for a specific product
     * 
     * GET /api/live-pricing/explain/{platform}/{id}
     */
    public function explain(string $platform, string $id): JsonResponse
    {
        $product = CachedAffiliateProduct::query()
            ->where('platform', $platform)
            ->where('platform_product_id', $id)
            ->first();

        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found',
            ], 404);
        }

        $productArray = $product->toNormalizedArray();
        $explanation = $this->simulator->explainPricing($productArray);

        return response()->json([
            'success' => true,
            'product' => $productArray,
            'explanation' => $explanation,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    /**
     * Toggle live pricing for user session
     * 
     * POST /api/live-pricing/toggle
     */
    public function toggle(Request $request): JsonResponse
    {
        $enabled = filter_var($request->input('enabled', true), FILTER_VALIDATE_BOOLEAN);
        
        // Store preference in session/cache
        $userId = $request->user()?->id ?? 'guest';
        Cache::put("live_pricing_enabled:{$userId}", $enabled, now()->addHours(24));

        return response()->json([
            'success' => true,
            'live_pricing_enabled' => $enabled,
            'message' => $enabled ? 'Live pricing enabled' : 'Live pricing disabled',
        ]);
    }

    /**
     * Get live pricing status
     * 
     * GET /api/live-pricing/status
     */
    public function status(Request $request): JsonResponse
    {
        $userId = $request->user()?->id ?? 'guest';
        $enabled = Cache::get("live_pricing_enabled:{$userId}", true);

        return response()->json([
            'success' => true,
            'live_pricing_enabled' => $enabled,
            'current_tick' => $this->simulator->getCurrentTick(),
            'interval_ms' => self::TICK_INTERVAL_SECONDS * 1000,
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    /**
     * Get products for update
     */
    private function getProductsForUpdate(array $platforms, int $limit): array
    {
        return CachedAffiliateProduct::query()
            ->when($platforms, fn($q) => $q->whereIn('platform', $platforms))
            ->inRandomOrder()
            ->limit($limit)
            ->get()
            ->map(fn($p) => $p->toNormalizedArray())
            ->toArray();
    }

    /**
     * Send SSE event
     */
    private function sendSSEEvent(string $event, array $data): void
    {
        echo "event: {$event}\n";
        echo "data: " . json_encode($data) . "\n";
        echo "retry: " . self::SSE_RETRY_MS . "\n\n";
    }
}
