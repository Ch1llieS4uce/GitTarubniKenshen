<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;

class CachedAffiliateProduct extends Model
{
    use HasFactory;

    protected $table = 'cached_affiliate_products';

    protected $fillable = [
        'platform',
        'platform_product_id',
        'title',
        'price',
        'original_price',
        'discount',
        'rating',
        'review_count',
        'seller_rating',
        'sales',
        'image',
        'url',
        'affiliate_url',
        'category',
        'extra_data',
        'synced_at',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'original_price' => 'decimal:2',
        'discount' => 'decimal:4',
        'rating' => 'decimal:2',
        'review_count' => 'integer',
        'seller_rating' => 'decimal:2',
        'sales' => 'integer',
        'extra_data' => 'array',
        'synced_at' => 'datetime',
    ];

    /**
     * Scope to filter by platform
     */
    public function scopePlatform(Builder $query, string $platform): Builder
    {
        return $query->where('platform', $platform);
    }

    /**
     * Scope for search query
     */
    public function scopeSearch(Builder $query, ?string $searchQuery): Builder
    {
        if (empty($searchQuery)) {
            return $query;
        }

        return $query->where(function ($q) use ($searchQuery) {
            $q->where('title', 'like', '%' . $searchQuery . '%')
              ->orWhere('category', 'like', '%' . $searchQuery . '%');
        });
    }

    /**
     * Scope for price range
     */
    public function scopePriceRange(Builder $query, ?float $minPrice, ?float $maxPrice): Builder
    {
        if ($minPrice !== null) {
            $query->where('price', '>=', $minPrice);
        }
        if ($maxPrice !== null) {
            $query->where('price', '<=', $maxPrice);
        }
        return $query;
    }

    /**
     * Scope for minimum rating
     */
    public function scopeMinRating(Builder $query, ?float $minRating): Builder
    {
        if ($minRating !== null) {
            $query->where('rating', '>=', $minRating);
        }
        return $query;
    }

    /**
     * Scope to get recently synced products
     */
    public function scopeRecentlySync(Builder $query, int $hoursAgo = 24): Builder
    {
        return $query->where('synced_at', '>=', now()->subHours($hoursAgo));
    }

    /**
     * Convert to normalized array format for API response
     */
    public function toNormalizedArray(): array
    {
        return [
            'id' => $this->platform_product_id,
            'platform' => $this->platform,
            'platform_product_id' => $this->platform_product_id,
            'title' => $this->title,
            'price' => (float)$this->price,
            'original_price' => $this->original_price ? (float)$this->original_price : null,
            'discount' => $this->discount ? (float)$this->discount : null,
            'rating' => $this->rating ? (float)$this->rating : null,
            'review_count' => $this->review_count,
            'seller_rating' => $this->seller_rating ? (float)$this->seller_rating : null,
            'sales' => $this->sales,
            'image' => $this->image ?: $this->getPlaceholderImage(),
            'url' => $this->url,
            'affiliate_url' => $this->affiliate_url ?: $this->url,
            'data_source' => sprintf('Data provided via %s Affiliate API (cached)', ucfirst($this->platform)),
        ];
    }

    /**
     * Get placeholder image when no image is available
     */
    protected function getPlaceholderImage(): string
    {
        $seed = md5($this->platform_product_id);
        return "https://picsum.photos/seed/{$seed}/300/300";
    }

    /**
     * Create or update from normalized product data
     */
    public static function upsertFromNormalized(string $platform, array $data): self
    {
        $productId = $data['id'] ?? $data['platform_product_id'] ?? null;
        
        if (!$productId) {
            throw new \InvalidArgumentException('Product must have an id or platform_product_id');
        }

        return static::updateOrCreate(
            [
                'platform' => $platform,
                'platform_product_id' => $productId,
            ],
            [
                'title' => $data['title'] ?? 'Unknown Product',
                'price' => $data['price'] ?? null,
                'original_price' => $data['original_price'] ?? null,
                'discount' => $data['discount'] ?? null,
                'rating' => $data['rating'] ?? null,
                'review_count' => $data['review_count'] ?? null,
                'seller_rating' => $data['seller_rating'] ?? null,
                'sales' => $data['sales'] ?? null,
                'image' => $data['image'] ?? null,
                'url' => $data['url'] ?? '',
                'affiliate_url' => $data['affiliate_url'] ?? null,
                'category' => $data['category'] ?? null,
                'extra_data' => array_diff_key($data, array_flip([
                    'id', 'platform_product_id', 'platform', 'title', 'price',
                    'original_price', 'discount', 'rating', 'review_count',
                    'seller_rating', 'sales', 'image', 'url', 'affiliate_url', 'category'
                ])),
                'synced_at' => now(),
            ]
        );
    }
}
