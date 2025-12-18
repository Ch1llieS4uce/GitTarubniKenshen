<?php

namespace App\Services\Affiliates;

use App\Services\Affiliates\Contracts\ProductSearchClient;

class TikTokShopClient implements ProductSearchClient
{
    public function search(string $query, int $page = 1, int $pageSize = 20): array
    {
        $products = $this->sampleProducts($query);
        return array_slice($products, ($page - 1) * $pageSize, $pageSize);
    }

    public function getProduct(string $platformProductId): array
    {
        $match = collect($this->sampleProducts(''))->firstWhere('id', $platformProductId);
        return $match ?? [];
    }

    public function createAffiliateLink(string $targetUrl): string
    {
        $glue = str_contains($targetUrl, '?') ? '&' : '?';
        return $targetUrl . $glue . 'aff_id=MOCK_TIKTOK';
    }

    protected function sampleProducts(string $query): array
    {
        $baseProducts = [
            // Trending/Viral Products
            [
                'id' => 'TT-3001',
                'title' => 'LED Ring Light 10 inch with Tripod Stand Phone Holder',
                'price' => 549.00,
                'original_price' => 899.00,
                'discount' => 0.39,
                'rating' => 4.7,
                'review_count' => 12450,
                'seller_rating' => 4.8,
                'sales' => 89000,
                'image' => 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/ring-light',
            ],
            [
                'id' => 'TT-3002',
                'title' => 'Phone Tripod Flexible Octopus Stand with Remote',
                'price' => 299.00,
                'original_price' => 499.00,
                'discount' => 0.40,
                'rating' => 4.5,
                'review_count' => 8760,
                'seller_rating' => 4.6,
                'sales' => 65000,
                'image' => 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/phone-tripod',
            ],
            [
                'id' => 'TT-3003',
                'title' => 'Wireless Lavalier Microphone for iPhone Android',
                'price' => 799.00,
                'original_price' => 1299.00,
                'discount' => 0.38,
                'rating' => 4.6,
                'review_count' => 5430,
                'seller_rating' => 4.7,
                'sales' => 42000,
                'image' => 'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/wireless-mic',
            ],
            // Beauty & Skincare (Viral)
            [
                'id' => 'TT-3004',
                'title' => 'Snail Mucin 96% Power Repairing Essence 100ml',
                'price' => 699.00,
                'original_price' => 999.00,
                'discount' => 0.30,
                'rating' => 4.9,
                'review_count' => 23450,
                'seller_rating' => 4.9,
                'sales' => 180000,
                'image' => 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/snail-mucin',
            ],
            [
                'id' => 'TT-3005',
                'title' => 'Lip Gloss Plumping Hydrating Clear Glass Finish',
                'price' => 199.00,
                'original_price' => 349.00,
                'discount' => 0.43,
                'rating' => 4.7,
                'review_count' => 15670,
                'seller_rating' => 4.8,
                'sales' => 125000,
                'image' => 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/lip-gloss',
            ],
            [
                'id' => 'TT-3006',
                'title' => 'Ice Roller Face Massager Skin Care Tool',
                'price' => 149.00,
                'original_price' => 299.00,
                'discount' => 0.50,
                'rating' => 4.5,
                'review_count' => 9870,
                'seller_rating' => 4.6,
                'sales' => 78000,
                'image' => 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/ice-roller',
            ],
            // Fashion (Trendy)
            [
                'id' => 'TT-3007',
                'title' => 'Claw Clip Large Hair Clip Matte Aesthetic Y2K',
                'price' => 79.00,
                'original_price' => 149.00,
                'discount' => 0.47,
                'rating' => 4.6,
                'review_count' => 18900,
                'seller_rating' => 4.7,
                'sales' => 250000,
                'image' => 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/claw-clip',
            ],
            [
                'id' => 'TT-3008',
                'title' => 'Cloud Slippers Soft Pillow Slides Indoor Outdoor',
                'price' => 299.00,
                'original_price' => 499.00,
                'discount' => 0.40,
                'rating' => 4.8,
                'review_count' => 34560,
                'seller_rating' => 4.9,
                'sales' => 320000,
                'image' => 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/cloud-slippers',
            ],
            [
                'id' => 'TT-3009',
                'title' => 'Aesthetic Tote Bag Canvas Large Capacity',
                'price' => 249.00,
                'original_price' => 399.00,
                'discount' => 0.38,
                'rating' => 4.5,
                'review_count' => 7650,
                'seller_rating' => 4.6,
                'sales' => 56000,
                'image' => 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/tote-bag',
            ],
            // Home & Kitchen (Viral)
            [
                'id' => 'TT-3010',
                'title' => 'Sunset Lamp Projector Rainbow Atmosphere Light',
                'price' => 399.00,
                'original_price' => 699.00,
                'discount' => 0.43,
                'rating' => 4.4,
                'review_count' => 6780,
                'seller_rating' => 4.5,
                'sales' => 48000,
                'image' => 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/sunset-lamp',
            ],
            [
                'id' => 'TT-3011',
                'title' => 'Mini Waffle Maker Electric Non-Stick Breakfast',
                'price' => 599.00,
                'original_price' => 899.00,
                'discount' => 0.33,
                'rating' => 4.7,
                'review_count' => 4320,
                'seller_rating' => 4.8,
                'sales' => 35000,
                'image' => 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/waffle-maker',
            ],
            [
                'id' => 'TT-3012',
                'title' => 'Portable Blender USB Rechargeable Smoothie Maker',
                'price' => 499.00,
                'original_price' => 799.00,
                'discount' => 0.38,
                'rating' => 4.6,
                'review_count' => 8970,
                'seller_rating' => 4.7,
                'sales' => 67000,
                'image' => 'https://images.unsplash.com/photo-1570197571499-166b36435e9f?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/portable-blender',
            ],
            // Tech Gadgets
            [
                'id' => 'TT-3013',
                'title' => 'Phone Camera Lens Kit Wide Angle Macro Fisheye',
                'price' => 349.00,
                'original_price' => 599.00,
                'discount' => 0.42,
                'rating' => 4.4,
                'review_count' => 3210,
                'seller_rating' => 4.5,
                'sales' => 28000,
                'image' => 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/phone-lens',
            ],
            [
                'id' => 'TT-3014',
                'title' => 'LED Strip Lights RGB 5M with Remote Music Sync',
                'price' => 299.00,
                'original_price' => 499.00,
                'discount' => 0.40,
                'rating' => 4.5,
                'review_count' => 11230,
                'seller_rating' => 4.6,
                'sales' => 92000,
                'image' => 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/led-strip',
            ],
            [
                'id' => 'TT-3015',
                'title' => 'Mini Thermal Printer Portable Pocket Photo Printer',
                'price' => 899.00,
                'original_price' => 1499.00,
                'discount' => 0.40,
                'rating' => 4.6,
                'review_count' => 2340,
                'seller_rating' => 4.7,
                'sales' => 18000,
                'image' => 'https://images.unsplash.com/photo-1612198188060-c7c2a3b66eae?w=300&h=300&fit=crop',
                'url' => 'https://www.tiktok.com/shop/mini-printer',
            ],
        ];

        $products = $this->expandProducts($baseProducts, 100, 'TT', 3101);

        // Add platform and affiliate URL to all products
        $products = array_map(function (array $product) {
            $product['platform'] = 'tiktok';
            $product['affiliate_url'] = $this->createAffiliateLink($product['url']);
            return $product;
        }, $products);

        // Filter by query if provided
        if (!empty($query)) {
            $query = strtolower($query);
            $products = array_values(array_filter($products, function ($item) use ($query) {
                return stripos(strtolower($item['title']), $query) !== false;
            }));

            // If no exact matches, return all products (simulating search)
            if (empty($products)) {
                $products = $this->expandProducts($baseProducts, 100, 'TT', 3101);
                return array_map(function (array $product) {
                    $product['platform'] = 'tiktok';
                    $product['affiliate_url'] = $this->createAffiliateLink($product['url']);
                    return $product;
                }, $products);
            }
        }

        return $products;
    }

    /**
     * Expand a base product catalog into a deterministic set.
     *
     * @param array<int, array<string, mixed>> $baseProducts
     * @return array<int, array<string, mixed>>
     */
    private function expandProducts(array $baseProducts, int $targetCount, string $idPrefix, int $startNumber): array
    {
        $adjectives = [
            'Viral',
            'Trending',
            'Creator Pick',
            'Hot Deal',
            'New Drop',
            'Budget-Friendly',
            'Limited Edition',
            'Pro',
            'Ultra',
            'Best Seller',
        ];
        $suffixes = [
            'Bundle',
            '2025',
            'Plus',
            'Max',
            'Lite',
            'Edition',
            'Set',
            'Pack',
            'Collection',
            'Series',
        ];

        $products = array_values($baseProducts);
        $baseCount = count($products);
        if ($baseCount === 0) {
            return [];
        }

        $i = 0;
        while (count($products) < $targetCount) {
            /** @var array<string, mixed> $template */
            $template = $baseProducts[$i % $baseCount];
            $number = $startNumber + $i;
            $id = sprintf('%s-%04d', $idPrefix, $number);

            $factor = 0.84 + (($i % 21) / 55); // ~0.84..1.22
            $basePrice = (float)($template['price'] ?? 0);
            $price = round($basePrice * $factor, 2);

            $baseDiscount = (float)($template['discount'] ?? 0.3);
            $delta = (($i % 7) - 3) * 0.015; // -0.045..+0.045
            $discount = min(0.80, max(0.05, $baseDiscount + $delta));
            $originalPrice = round($price / (1 - $discount), 2);

            $baseRating = (float)($template['rating'] ?? 4.6);
            $ratingDelta = (($i % 9) - 4) * 0.05; // -0.20..+0.20
            $rating = min(5.0, max(3.6, round($baseRating + $ratingDelta, 1)));

            $baseReviews = (int)($template['review_count'] ?? 500);
            $reviewCount = max(0, $baseReviews + ($i * 41));

            $url = (string)($template['url'] ?? '');
            $glue = str_contains($url, '?') ? '&' : '?';
            $url = $url !== '' ? $url . $glue . 'mock_id=' . $id : 'https://www.tiktok.com/shop/mock?mock_id=' . $id;

            $image = (string)($template['image'] ?? '');
            if ($image !== '') {
                $imageGlue = str_contains($image, '?') ? '&' : '?';
                $image .= $imageGlue . 'mock=' . $id;
            }

            $title = sprintf(
                '%s %s %s #%d',
                $adjectives[$i % count($adjectives)],
                (string)($template['title'] ?? 'Product'),
                $suffixes[$i % count($suffixes)],
                $i + 1
            );

            $products[] = array_merge($template, [
                'id' => $id,
                'sku' => 'SKU-' . $id,
                'title' => $title,
                'price' => $price,
                'original_price' => $originalPrice,
                'discount' => $discount,
                'rating' => $rating,
                'review_count' => $reviewCount,
                'url' => $url,
                'image' => $image,
            ]);

            $i++;
        }

        return array_slice($products, 0, $targetCount);
    }
}
