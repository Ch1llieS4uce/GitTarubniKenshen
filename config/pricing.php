<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Pricing & AI Recommendation Settings
    |--------------------------------------------------------------------------
    |
    | Keep all env lookups inside config so `php artisan config:cache` remains
    | safe for production deployments.
    |
    */

    'ai_price_engine_url' => env('AI_PRICE_ENGINE_URL'),

    // Formula defaults (see .env.example)
    'alpha' => (float) env('PRICING_ALPHA', 0.65),
    'beta' => (float) env('PRICING_BETA', 0.35),
    'gamma_multiplier' => (float) env('PRICING_GAMMA_MULTIPLIER', 0.05),
    'competitive_ceiling_pct' => (float) env('PRICING_COMPETITIVE_CEILING_PCT', 0.05),
];

