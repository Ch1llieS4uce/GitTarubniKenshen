<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class AffiliateProductResource extends JsonResource
{
    public function toArray($request): array
    {
        $ai = $this['ai_recommendation'] ?? null;
        $ai = is_array($ai) ? $ai : [];

        return [
            'platform' => $this['platform'] ?? null,
            'platform_product_id' => $this['id'] ?? null,
            'title' => $this['title'] ?? null,
            'price' => $this['price'] ?? null,
            'original_price' => $this['original_price'] ?? null,
            'discount' => $this['discount'] ?? null,
            'rating' => $this['rating'] ?? null,
            'review_count' => $this['review_count'] ?? null,
            'seller_rating' => $this['seller_rating'] ?? null,
            'image' => $this['image'] ?? null,
            'url' => $this['url'] ?? null,
            'affiliate_url' => $this['affiliate_url'] ?? null,
            'ai_recommendation' => [
                'recommended_price' => $this['recommended_price'] ?? ($ai['recommended_price'] ?? null),
                'confidence' => $this['confidence'] ?? ($ai['confidence'] ?? null),
                'reason' => $ai['reason'] ?? null,
                'source' => $ai['source'] ?? null,
                'model_version' => $ai['model_version'] ?? null,
            ],
            'data_source' => $this['data_source'] ?? 'Platform API',
        ];
    }
}
