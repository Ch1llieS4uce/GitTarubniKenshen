<?php

namespace App\Http\Controllers;

use App\Models\Listing;
use App\Models\Recommendation;
use App\Services\Pricing\PriceRecommendationEngine;
use Illuminate\Http\Request;

class RecommendationController extends Controller
{
    public function getRecommendation(Request $request, $listingId, PriceRecommendationEngine $engine)
    {
        $listingQuery = Listing::with('product');

        if (($request->user()?->role ?? 'seller') !== 'admin') {
            $listingQuery->whereHas('product', fn ($q) => $q->where('user_id', $request->user()->id));
        }

        $listing = $listingQuery->findOrFail($listingId);

        $rec = $engine->recommendForListing($listing);

        $saved = Recommendation::create([
            'listing_id' => $listing->id,
            'recommended_price' => $rec['recommended_price'],
            'confidence' => $rec['confidence'] * 100,
            'model_version' => $rec['model_version'],
            'generated_at' => now(),
        ]);

        return response()->json([
            'listing_id' => $listing->id,
            'recommended_price' => (float)$saved->recommended_price,
            'confidence' => (float)$saved->confidence,
            'model_version' => $saved->model_version,
            'generated_at' => $saved->generated_at,
        ]);
    }
}

