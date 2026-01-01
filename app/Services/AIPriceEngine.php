<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * AI Price Engine Service
 * 
 * Interfaces with the Python AI pricing recommendation engine.
 * Provides explainable price recommendations based on:
 * - Competitor pricing
 * - Cost and margin requirements
 * - Demand factors
 * - Stock levels
 * 
 * @version 2.0.0
 */
class AIPriceEngine
{
    private string $baseUrl;
    private int $timeout;

    public function __construct()
    {
        $this->baseUrl = config('services.ai_price_engine.url', 'http://127.0.0.1:9010');
        $this->timeout = config('services.ai_price_engine.timeout', 5);
    }

    /**
     * Get AI price recommendation
     *
     * @param array $params Pricing parameters
     * @param bool $explain Include detailed explanation
     * @return array Recommendation with confidence and optional explanation
     */
    public function recommend(array $params, bool $explain = false): array
    {
        $payload = array_merge($params, [
            'explain' => $explain,
        ]);

        try {
            $response = Http::timeout($this->timeout)
                ->post("{$this->baseUrl}/recommend", $payload);

            if ($response->successful()) {
                return $response->json();
            }

            Log::warning('AI Price Engine returned error', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return $this->fallbackRecommendation($params);
        } catch (\Throwable $e) {
            Log::error('AI Price Engine request failed', [
                'error' => $e->getMessage(),
            ]);

            return $this->fallbackRecommendation($params);
        }
    }

    /**
     * Fallback recommendation when AI engine is unavailable
     */
    private function fallbackRecommendation(array $params): array
    {
        $competitorAvg = $params['competitor_avg'] ?? $params['current_price'] ?? 100;
        $minPrice = $params['min_price'] ?? ($params['cost_price'] ?? $competitorAvg * 0.6) * 1.3;
        $demandFactor = $params['demand_factor'] ?? 0.5;

        // Simple weighted formula
        $alpha = 0.65;
        $beta = 0.35;
        $gamma = 0.05;

        $recommended = ($alpha * $competitorAvg) + ($beta * $minPrice) + ($gamma * $competitorAvg * $demandFactor);
        $ceiling = $competitorAvg * 1.07;
        $recommended = max($minPrice, min($ceiling, $recommended));

        return [
            'recommended_price' => round($recommended, 2),
            'confidence' => 0.55,
            'model_version' => 'fallback-v1',
            'source' => 'fallback',
        ];
    }

    /**
     * Check if AI engine is healthy
     */
    public function health(): array
    {
        try {
            $response = Http::timeout(2)->get("{$this->baseUrl}/health");
            
            return [
                'status' => $response->successful() ? 'healthy' : 'unhealthy',
                'response_time_ms' => $response->handlerStats()['total_time'] ?? null,
            ];
        } catch (\Throwable $e) {
            return [
                'status' => 'unavailable',
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Explain the pricing algorithm for a product
     */
    public function explainAlgorithm(array $product): array
    {
        $costPrice = ($product['original_price'] ?? $product['price'] * 1.2) * 0.6;
        $minPrice = $costPrice * 1.3;
        $competitorAvg = $product['competitor_avg'] ?? $product['price'] * 1.05;
        $demandFactor = $product['demand_factor'] ?? 0.5;

        // Get full recommendation with explanation
        $recommendation = $this->recommend([
            'current_price' => $product['price'],
            'competitor_avg' => $competitorAvg,
            'demand_factor' => $demandFactor,
            'cost_price' => $costPrice,
            'min_price' => $minPrice,
            'desired_margin' => 0.3,
        ], explain: true);

        return [
            'algorithm_name' => 'Weighted Price Optimization Algorithm v2',
            'model_version' => $recommendation['model_version'] ?? 'mock-formula-v2',
            'formula' => [
                'expression' => 'P_recommended = α × P_competitor + β × P_min + γ × P_competitor × D_factor',
                'latex' => 'P_{recommended} = \\alpha \\cdot P_c + \\beta \\cdot P_{min} + \\gamma \\cdot P_c \\cdot D_f',
            ],
            'weights' => [
                'alpha' => ['value' => 0.65, 'description' => 'Competitor price weight'],
                'beta' => ['value' => 0.35, 'description' => 'Minimum price weight'],
                'gamma' => ['value' => 0.05, 'description' => 'Demand adjustment multiplier'],
            ],
            'inputs' => [
                'competitor_avg' => $competitorAvg,
                'min_price' => $minPrice,
                'demand_factor' => $demandFactor,
                'cost_price' => $costPrice,
            ],
            'recommendation' => $recommendation,
            'constraints' => [
                'min_price' => ['value' => $minPrice, 'description' => 'Cost + 30% margin floor'],
                'ceiling' => ['value' => $competitorAvg * 1.07, 'description' => 'Max 7% above competitor avg'],
            ],
        ];
    }
}
