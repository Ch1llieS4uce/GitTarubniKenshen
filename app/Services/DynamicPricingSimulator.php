<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

/**
 * Dynamic Pricing Simulator
 * 
 * Simulates real-time market conditions for thesis demonstration.
 * Uses bounded random-walk algorithm with safeguards.
 * 
 * Algorithm:
 * - Every tick (3 seconds), 5-15% of products get price updates
 * - Price delta: ±0.2% to ±1.5% bounded random-walk
 * - Exponential Moving Average (EMA) smoothing prevents flickering
 * - Hard clamps ensure prices never violate min_price or ceiling
 * 
 * @version 1.0.0
 * @author BaryaBest Thesis Team
 */
class DynamicPricingSimulator
{
    /** Percentage of products to update per tick */
    private const UPDATE_PERCENT_MIN = 0.05;
    private const UPDATE_PERCENT_MAX = 0.15;

    /** Price delta bounds (as percentage) */
    private const PRICE_DELTA_MIN = 0.002; // 0.2%
    private const PRICE_DELTA_MAX = 0.015; // 1.5%

    /** EMA smoothing factor (0-1, higher = more responsive) */
    private const EMA_ALPHA = 0.3;

    /** Demand factor fluctuation bounds */
    private const DEMAND_DELTA_MAX = 0.05;

    /** Competitor price fluctuation bounds */
    private const COMPETITOR_DELTA_MAX = 0.02;

    /** Cache key prefix for product states */
    private const CACHE_PREFIX = 'dynamic_pricing:';

    /** Fixed seed for demo stability (null for random) */
    private ?int $fixedSeed = null;

    /** AI Price Engine service */
    private AIPriceEngine $priceEngine;

    public function __construct(AIPriceEngine $priceEngine)
    {
        $this->priceEngine = $priceEngine;
    }

    /**
     * Enable fixed seed mode for panel demo stability
     */
    public function setFixedSeed(?int $seed): self
    {
        $this->fixedSeed = $seed;
        if ($seed !== null) {
            mt_srand($seed);
        }
        return $this;
    }

    /**
     * Get current tick timestamp (3-second intervals)
     */
    public function getCurrentTick(): int
    {
        return (int) floor(time() / 3);
    }

    /**
     * Simulate price updates for a batch of products
     *
     * @param array $products Array of products with current pricing data
     * @return array Updated products with new prices and AI recommendations
     */
    public function simulateTick(array $products): array
    {
        if (empty($products)) {
            return [];
        }

        $tick = $this->getCurrentTick();
        $updateCount = $this->calculateUpdateCount(count($products));
        
        // Select products to update (deterministic if fixed seed)
        $indicesToUpdate = $this->selectProductsToUpdate(count($products), $updateCount, $tick);
        
        $updatedProducts = [];
        
        foreach ($indicesToUpdate as $index) {
            if (!isset($products[$index])) {
                continue;
            }
            
            $product = $products[$index];
            $updatedProduct = $this->updateProductPricing($product, $tick);
            $updatedProducts[] = $updatedProduct;
        }

        return $updatedProducts;
    }

    /**
     * Calculate how many products to update this tick
     */
    private function calculateUpdateCount(int $totalProducts): int
    {
        $percent = $this->randomFloat(self::UPDATE_PERCENT_MIN, self::UPDATE_PERCENT_MAX);
        return max(1, (int) ceil($totalProducts * $percent));
    }

    /**
     * Select which product indices to update
     */
    private function selectProductsToUpdate(int $total, int $count, int $tick): array
    {
        $indices = [];
        
        if ($this->fixedSeed !== null) {
            // Deterministic selection based on tick for demo reproducibility
            for ($i = 0; $i < $count; $i++) {
                $indices[] = ($tick * 7 + $i * 13) % $total;
            }
        } else {
            // Random selection
            $available = range(0, $total - 1);
            shuffle($available);
            $indices = array_slice($available, 0, $count);
        }

        return array_unique($indices);
    }

    /**
     * Update a single product's pricing with bounded random-walk
     */
    private function updateProductPricing(array $product, int $tick): array
    {
        $productId = $product['id'] ?? $product['platform_product_id'] ?? uniqid();
        $platform = $product['platform'] ?? 'unknown';
        $cacheKey = self::CACHE_PREFIX . $platform . ':' . $productId;

        // Get previous state or initialize
        $state = Cache::get($cacheKey, [
            'price' => $product['price'] ?? 0,
            'competitor_avg' => $product['competitor_avg'] ?? ($product['price'] ?? 0) * 1.05,
            'demand_factor' => $product['demand_factor'] ?? 0.5,
            'ema_price' => $product['price'] ?? 0,
            'last_tick' => $tick - 1,
        ]);

        // Calculate new values with bounded random-walk
        $newPrice = $this->applyRandomWalk(
            $state['price'],
            self::PRICE_DELTA_MIN,
            self::PRICE_DELTA_MAX
        );

        $newCompetitorAvg = $this->applyRandomWalk(
            $state['competitor_avg'],
            self::COMPETITOR_DELTA_MAX * 0.5,
            self::COMPETITOR_DELTA_MAX
        );

        $newDemandFactor = $this->applyRandomWalkClamped(
            $state['demand_factor'],
            self::DEMAND_DELTA_MAX,
            0.1, // min demand
            0.95 // max demand
        );

        // Apply EMA smoothing to prevent flickering
        $smoothedPrice = $this->applyEMA($state['ema_price'], $newPrice);

        // Calculate min_price (cost + margin) - assume 30% margin from original price
        $originalPrice = $product['original_price'] ?? $newPrice * 1.2;
        $costPrice = $originalPrice * 0.6; // Assume 40% is cost
        $minPrice = $costPrice * 1.3; // 30% minimum margin

        // Apply hard clamps
        $ceiling = $newCompetitorAvg * 1.15; // 15% above competitor avg
        $clampedPrice = max($minPrice, min($ceiling, $smoothedPrice));

        // Get AI recommendation
        $aiRecommendation = $this->getAIRecommendation([
            'current_price' => $clampedPrice,
            'competitor_avg' => $newCompetitorAvg,
            'demand_factor' => $newDemandFactor,
            'cost_price' => $costPrice,
            'min_price' => $minPrice,
            'desired_margin' => 0.3,
        ]);

        // Update state in cache
        $newState = [
            'price' => $clampedPrice,
            'competitor_avg' => $newCompetitorAvg,
            'demand_factor' => $newDemandFactor,
            'ema_price' => $smoothedPrice,
            'last_tick' => $tick,
        ];
        Cache::put($cacheKey, $newState, now()->addMinutes(30));

        // Return updated product
        return array_merge($product, [
            'price' => round($clampedPrice, 2),
            'competitor_avg' => round($newCompetitorAvg, 2),
            'demand_factor' => round($newDemandFactor, 4),
            'recommended_price' => $aiRecommendation['recommended_price'] ?? null,
            'confidence' => $aiRecommendation['confidence'] ?? null,
            'recommended_savings' => $aiRecommendation['recommended_price'] 
                ? round($clampedPrice - $aiRecommendation['recommended_price'], 2) 
                : null,
            'model_version' => $aiRecommendation['model_version'] ?? 'mock-formula-v2',
            'pricing_updated_at' => now()->toIso8601String(),
            'tick' => $tick,
            'pricing_metadata' => [
                'min_price' => round($minPrice, 2),
                'ceiling' => round($ceiling, 2),
                'cost_price' => round($costPrice, 2),
                'ema_applied' => true,
                'clamp_applied' => $clampedPrice !== $smoothedPrice,
            ],
        ]);
    }

    /**
     * Apply bounded random-walk to a value
     */
    private function applyRandomWalk(float $value, float $minDelta, float $maxDelta): float
    {
        $delta = $this->randomFloat($minDelta, $maxDelta);
        $direction = $this->randomFloat(-1, 1) > 0 ? 1 : -1;
        return $value * (1 + ($direction * $delta));
    }

    /**
     * Apply bounded random-walk with hard clamps
     */
    private function applyRandomWalkClamped(float $value, float $maxDelta, float $min, float $max): float
    {
        $delta = $this->randomFloat(0, $maxDelta);
        $direction = $this->randomFloat(-1, 1) > 0 ? 1 : -1;
        $newValue = $value + ($direction * $delta);
        return max($min, min($max, $newValue));
    }

    /**
     * Apply Exponential Moving Average smoothing
     */
    private function applyEMA(float $previousEMA, float $newValue): float
    {
        return (self::EMA_ALPHA * $newValue) + ((1 - self::EMA_ALPHA) * $previousEMA);
    }

    /**
     * Get random float between min and max
     */
    private function randomFloat(float $min, float $max): float
    {
        return $min + (mt_rand() / mt_getrandmax()) * ($max - $min);
    }

    /**
     * Get AI price recommendation
     */
    private function getAIRecommendation(array $params): array
    {
        try {
            return $this->priceEngine->recommend($params);
        } catch (\Throwable $e) {
            Log::warning('AI recommendation failed, using fallback', [
                'error' => $e->getMessage(),
            ]);
            
            // Fallback calculation
            $competitorAvg = $params['competitor_avg'] ?? $params['current_price'];
            $minPrice = $params['min_price'] ?? $params['current_price'] * 0.7;
            
            $recommended = ($competitorAvg * 0.65) + ($minPrice * 0.35);
            $recommended = max($minPrice, min($competitorAvg * 1.07, $recommended));
            
            return [
                'recommended_price' => round($recommended, 2),
                'confidence' => 0.6,
                'model_version' => 'fallback-v1',
            ];
        }
    }

    /**
     * Get pricing explanation for a product (for UI breakdown)
     */
    public function explainPricing(array $product): array
    {
        $costPrice = ($product['original_price'] ?? $product['price'] * 1.2) * 0.6;
        $minPrice = $costPrice * 1.3;
        $competitorAvg = $product['competitor_avg'] ?? $product['price'] * 1.05;
        $demandFactor = $product['demand_factor'] ?? 0.5;

        $alpha = 0.65;
        $beta = 0.35;
        $gammaMultiplier = 0.05;

        $gamma = $gammaMultiplier * $competitorAvg;
        $alphaComponent = $alpha * $competitorAvg;
        $betaComponent = $beta * $minPrice;
        $gammaComponent = $gamma * $demandFactor;

        $candidateRaw = $alphaComponent + $betaComponent + $gammaComponent;
        $ceiling = $competitorAvg * 1.07;
        $recommended = max($minPrice, min($ceiling, $candidateRaw));

        return [
            'algorithm' => 'Weighted Price Optimization v2',
            'formula' => 'P = α×Pc + β×Pmin + γ×Pc×Df',
            'inputs' => [
                'competitor_avg' => [
                    'value' => round($competitorAvg, 2),
                    'description' => 'Average price across competing platforms',
                    'weight' => 'α = ' . $alpha,
                ],
                'min_price' => [
                    'value' => round($minPrice, 2),
                    'description' => 'Cost + 30% minimum margin',
                    'weight' => 'β = ' . $beta,
                ],
                'demand_factor' => [
                    'value' => round($demandFactor, 4),
                    'description' => 'Market demand indicator (0-1)',
                    'weight' => 'γ = ' . $gammaMultiplier,
                ],
            ],
            'components' => [
                'alpha_contribution' => [
                    'value' => round($alphaComponent, 2),
                    'formula' => "α × Pc = {$alpha} × " . round($competitorAvg, 2),
                ],
                'beta_contribution' => [
                    'value' => round($betaComponent, 2),
                    'formula' => "β × Pmin = {$beta} × " . round($minPrice, 2),
                ],
                'gamma_contribution' => [
                    'value' => round($gammaComponent, 2),
                    'formula' => "γ × Pc × Df = {$gammaMultiplier} × " . round($competitorAvg, 2) . " × " . round($demandFactor, 4),
                ],
            ],
            'calculation' => [
                'candidate_raw' => round($candidateRaw, 2),
                'ceiling' => round($ceiling, 2),
                'min_price' => round($minPrice, 2),
                'clamp_applied' => $recommended !== $candidateRaw,
                'final_recommended' => round($recommended, 2),
            ],
            'explanation' => $this->generateExplanation($recommended, $competitorAvg, $minPrice, $demandFactor),
        ];
    }

    /**
     * Generate human-readable explanation
     */
    private function generateExplanation(float $recommended, float $competitorAvg, float $minPrice, float $demandFactor): string
    {
        $reasons = [];

        if ($demandFactor > 0.7) {
            $reasons[] = "High demand ({$demandFactor}) supports premium pricing";
        } elseif ($demandFactor < 0.3) {
            $reasons[] = "Low demand ({$demandFactor}) suggests competitive pricing";
        }

        if ($recommended < $competitorAvg) {
            $pctBelow = round((1 - $recommended / $competitorAvg) * 100, 1);
            $reasons[] = "Price is {$pctBelow}% below competitor average for market advantage";
        } elseif ($recommended > $competitorAvg) {
            $pctAbove = round(($recommended / $competitorAvg - 1) * 100, 1);
            $reasons[] = "Price is {$pctAbove}% above competitor average due to demand";
        }

        if ($recommended <= $minPrice * 1.05) {
            $reasons[] = "Price is near minimum to maintain profit margin";
        }

        return implode('. ', $reasons) . '.';
    }
}
