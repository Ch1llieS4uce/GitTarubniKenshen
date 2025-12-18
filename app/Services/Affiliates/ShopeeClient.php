<?php

namespace App\Services\Affiliates;

use App\Services\Affiliates\Contracts\ProductSearchClient;

class ShopeeClient implements ProductSearchClient
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
        return $targetUrl . $glue . 'aff_id=MOCK_SHOPEE';
    }

    protected function sampleProducts(string $query): array
    {
        $baseProducts = [
            // Electronics
            [
                'id' => 'SP-2001',
                'title' => 'Wireless Bluetooth Earbuds TWS 5.0 with Charging Case',
                'price' => 799.00,
                'original_price' => 1299.00,
                'discount' => 0.38,
                'rating' => 4.8,
                'review_count' => 15420,
                'seller_rating' => 4.9,
                'sales' => 50000,
                'image' => 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/earbuds-tws',
            ],
            [
                'id' => 'SP-2002',
                'title' => 'Phone Case Shockproof Clear TPU iPhone/Samsung',
                'price' => 89.00,
                'original_price' => 199.00,
                'discount' => 0.55,
                'rating' => 4.6,
                'review_count' => 8420,
                'seller_rating' => 4.7,
                'sales' => 120000,
                'image' => 'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/phone-case',
            ],
            [
                'id' => 'SP-2003',
                'title' => 'USB-C Fast Charging Cable 1.5M Braided Nylon',
                'price' => 79.00,
                'original_price' => 150.00,
                'discount' => 0.47,
                'rating' => 4.7,
                'review_count' => 22150,
                'seller_rating' => 4.8,
                'sales' => 200000,
                'image' => 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/usb-cable',
            ],
            [
                'id' => 'SP-2004',
                'title' => 'Portable Power Bank 20000mAh Fast Charge PD 65W',
                'price' => 1299.00,
                'original_price' => 1999.00,
                'discount' => 0.35,
                'rating' => 4.9,
                'review_count' => 5820,
                'seller_rating' => 4.9,
                'sales' => 35000,
                'image' => 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/power-bank',
            ],
            // Fashion
            [
                'id' => 'SP-2005',
                'title' => 'Korean Style Oversized T-Shirt Unisex Cotton',
                'price' => 199.00,
                'original_price' => 399.00,
                'discount' => 0.50,
                'rating' => 4.5,
                'review_count' => 12300,
                'seller_rating' => 4.6,
                'sales' => 85000,
                'image' => 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/oversized-tshirt',
            ],
            [
                'id' => 'SP-2006',
                'title' => 'Canvas Sneakers Casual Shoes Men Women Unisex',
                'price' => 599.00,
                'original_price' => 999.00,
                'discount' => 0.40,
                'rating' => 4.4,
                'review_count' => 6780,
                'seller_rating' => 4.5,
                'sales' => 45000,
                'image' => 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/canvas-sneakers',
            ],
            [
                'id' => 'SP-2007',
                'title' => 'Minimalist Watch Stainless Steel Quartz Analog',
                'price' => 449.00,
                'original_price' => 899.00,
                'discount' => 0.50,
                'rating' => 4.6,
                'review_count' => 3420,
                'seller_rating' => 4.7,
                'sales' => 28000,
                'image' => 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/minimalist-watch',
            ],
            // Home & Living
            [
                'id' => 'SP-2008',
                'title' => 'LED Desk Lamp Eye Protection Reading Light USB',
                'price' => 299.00,
                'original_price' => 499.00,
                'discount' => 0.40,
                'rating' => 4.7,
                'review_count' => 4560,
                'seller_rating' => 4.8,
                'sales' => 32000,
                'image' => 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/desk-lamp',
            ],
            [
                'id' => 'SP-2009',
                'title' => 'Kitchen Organizer Storage Rack Stainless Steel',
                'price' => 399.00,
                'original_price' => 699.00,
                'discount' => 0.43,
                'rating' => 4.5,
                'review_count' => 2890,
                'seller_rating' => 4.6,
                'sales' => 18000,
                'image' => 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/kitchen-organizer',
            ],
            [
                'id' => 'SP-2010',
                'title' => 'Throw Pillow Cover Cushion Case Velvet 45x45cm',
                'price' => 99.00,
                'original_price' => 199.00,
                'discount' => 0.50,
                'rating' => 4.4,
                'review_count' => 5670,
                'seller_rating' => 4.5,
                'sales' => 65000,
                'image' => 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/pillow-cover',
            ],
            // Beauty & Health
            [
                'id' => 'SP-2011',
                'title' => 'Facial Cleanser Foam Gentle Deep Clean 150ml',
                'price' => 189.00,
                'original_price' => 299.00,
                'discount' => 0.37,
                'rating' => 4.8,
                'review_count' => 9870,
                'seller_rating' => 4.9,
                'sales' => 78000,
                'image' => 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/facial-cleanser',
            ],
            [
                'id' => 'SP-2012',
                'title' => 'Makeup Brush Set 12pcs Professional with Pouch',
                'price' => 349.00,
                'original_price' => 599.00,
                'discount' => 0.42,
                'rating' => 4.6,
                'review_count' => 4320,
                'seller_rating' => 4.7,
                'sales' => 42000,
                'image' => 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/makeup-brush-set',
            ],
            // Gadgets
            [
                'id' => 'SP-2013',
                'title' => 'Smart Watch Fitness Tracker Heart Rate Monitor',
                'price' => 1499.00,
                'original_price' => 2499.00,
                'discount' => 0.40,
                'rating' => 4.7,
                'review_count' => 7650,
                'seller_rating' => 4.8,
                'sales' => 55000,
                'image' => 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/smart-watch',
            ],
            [
                'id' => 'SP-2014',
                'title' => 'Wireless Mouse Rechargeable Silent Click RGB',
                'price' => 299.00,
                'original_price' => 499.00,
                'discount' => 0.40,
                'rating' => 4.5,
                'review_count' => 3210,
                'seller_rating' => 4.6,
                'sales' => 28000,
                'image' => 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/wireless-mouse',
            ],
            [
                'id' => 'SP-2015',
                'title' => 'Mechanical Gaming Keyboard RGB Backlit Blue Switch',
                'price' => 1299.00,
                'original_price' => 1999.00,
                'discount' => 0.35,
                'rating' => 4.8,
                'review_count' => 2890,
                'seller_rating' => 4.9,
                'sales' => 22000,
                'image' => 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=300&h=300&fit=crop',
                'url' => 'https://shopee.ph/product/gaming-keyboard',
            ],
        ];

        $products = $this->expandProducts($baseProducts, 100, 'SP', 2101);

        // Add platform and affiliate URL to all products
        $products = array_map(function (array $product) {
            $product['platform'] = 'shopee';
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
                $products = $this->expandProducts($baseProducts, 100, 'SP', 2101);
                return array_map(function (array $product) {
                    $product['platform'] = 'shopee';
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
            'Premium',
            'Best Seller',
            'Limited Edition',
            'Budget-Friendly',
            'Pro',
            'Ultra',
            'Compact',
            'Durable',
            'New',
            'Trending',
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

            $factor = 0.85 + (($i % 17) / 50); // 0.85..1.17
            $basePrice = (float)($template['price'] ?? 0);
            $price = round($basePrice * $factor, 2);

            $baseDiscount = (float)($template['discount'] ?? 0.2);
            $delta = (($i % 5) - 2) * 0.02; // -0.04..+0.04
            $discount = min(0.75, max(0.05, $baseDiscount + $delta));
            $originalPrice = round($price / (1 - $discount), 2);

            $baseRating = (float)($template['rating'] ?? 4.5);
            $ratingDelta = (($i % 9) - 4) * 0.05; // -0.20..+0.20
            $rating = min(5.0, max(3.5, round($baseRating + $ratingDelta, 1)));

            $baseReviews = (int)($template['review_count'] ?? 100);
            $reviewCount = max(0, $baseReviews + ($i * 37));

            $glue = str_contains((string)($template['url'] ?? ''), '?') ? '&' : '?';
            $url = (string)($template['url'] ?? '');
            $url = $url !== '' ? $url . $glue . 'mock_id=' . $id : 'https://shopee.ph/product/mock?mock_id=' . $id;

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
