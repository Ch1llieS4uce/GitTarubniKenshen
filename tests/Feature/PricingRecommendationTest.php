<?php

namespace Tests\Feature;

use App\Models\Listing;
use App\Models\PlatformAccount;
use App\Models\PriceHistory;
use App\Models\Product;
use App\Models\User;
use App\Services\Pricing\PriceRecommendationEngine;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class PricingRecommendationTest extends TestCase
{
    use RefreshDatabase;

    public function test_ai_override_is_bounded_by_min_price(): void
    {
        $user = User::factory()->create();
        $product = Product::create([
            'user_id' => $user->id,
            'title' => 'Wireless Bluetooth Earbuds',
            'sku' => 'SKU-TEST-1',
            'cost_price' => 100.00,
            'desired_margin' => 20.00,
        ]);

        $account = PlatformAccount::create([
            'user_id' => $user->id,
            'platform' => 'shopee',
            'account_name' => 'Test Account',
        ]);

        $listing = Listing::create([
            'product_id' => $product->id,
            'platform_account_id' => $account->id,
            'platform_product_id' => 'SP-TEST-1',
            'price' => 150.00,
            'stock' => 10,
            'status' => 'active',
        ]);

        putenv('AI_PRICE_ENGINE_URL=http://ai.test/recommend');
        $_ENV['AI_PRICE_ENGINE_URL'] = 'http://ai.test/recommend';

        Http::fake([
            'http://ai.test/recommend' => Http::response([
                'recommended_price' => 1,
                'confidence' => 0.9,
                'model_version' => 'unit-test-remote',
            ], 200),
        ]);

        $engine = app(PriceRecommendationEngine::class);
        $rec = $engine->recommendForListing($listing->fresh('product'));

        // min price = 100 * (1 + 0.20) = 120
        $this->assertSame(120.0, $rec['recommended_price']);
        $this->assertSame('unit-test-remote', $rec['model_version']);
    }

    public function test_formula_fallback_generates_competitive_price_and_records_market_snapshot(): void
    {
        putenv('AI_PRICE_ENGINE_URL=');
        $_ENV['AI_PRICE_ENGINE_URL'] = '';

        $user = User::factory()->create();
        $product = Product::create([
            'user_id' => $user->id,
            'title' => 'Phone Case Shockproof Clear TPU',
            'sku' => 'SKU-TEST-2',
            'cost_price' => 50.00,
            'desired_margin' => 30.00,
        ]);

        $account = PlatformAccount::create([
            'user_id' => $user->id,
            'platform' => 'shopee',
            'account_name' => 'Test Account',
        ]);

        $listing = Listing::create([
            'product_id' => $product->id,
            'platform_account_id' => $account->id,
            'platform_product_id' => 'SP-TEST-2',
            'price' => 80.00,
            'stock' => 5,
            'status' => 'active',
        ]);

        $engine = app(PriceRecommendationEngine::class);
        $rec = $engine->recommendForListing($listing->fresh('product'));

        $minPrice = 50.00 * (1 + 0.30);
        $this->assertGreaterThanOrEqual($minPrice, $rec['recommended_price']);

        $this->assertDatabaseCount('price_histories', 1);
        $this->assertDatabaseHas('price_histories', [
            'listing_id' => $listing->id,
            'source' => 'competitor',
        ]);

        $competitorAvg = (float)PriceHistory::where('listing_id', $listing->id)
            ->where('source', 'competitor')
            ->latest('recorded_at')
            ->value('price');

        $ceiling = max($minPrice, $competitorAvg * 1.05);
        $this->assertLessThanOrEqual(round($ceiling, 2), $rec['recommended_price']);
    }
}

