<?php

namespace App\Services\Affiliates;

use App\Services\Affiliates\Contracts\ProductSearchClient;

class LazadaClient implements ProductSearchClient
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
        return $targetUrl . $glue . 'aff_id=MOCK_LAZADA';
    }

    protected function sampleProducts(string $query): array
    {
        $baseProducts = [
            // Electronics
            [
                'id' => 'LZ-1001',
                'title' => 'Sony Wireless Noise Cancelling Headphones WH-1000XM5',
                'price' => 15999.00,
                'original_price' => 19999.00,
                'discount' => 0.20,
                'rating' => 4.9,
                'review_count' => 3254,
                'seller_rating' => 4.9,
                'sales' => 12000,
                'image' => 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/sony-headphones',
            ],
            [
                'id' => 'LZ-1002',
                'title' => 'Samsung Galaxy Watch 6 Classic 47mm',
                'price' => 18999.00,
                'original_price' => 22999.00,
                'discount' => 0.17,
                'rating' => 4.8,
                'review_count' => 1876,
                'seller_rating' => 4.8,
                'sales' => 8500,
                'image' => 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/galaxy-watch',
            ],
            [
                'id' => 'LZ-1003',
                'title' => 'Apple AirPods Pro 2nd Generation with MagSafe',
                'price' => 13499.00,
                'original_price' => 14990.00,
                'discount' => 0.10,
                'rating' => 4.9,
                'review_count' => 5678,
                'seller_rating' => 5.0,
                'sales' => 25000,
                'image' => 'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/airpods-pro',
            ],
            [
                'id' => 'LZ-1004',
                'title' => 'JBL Flip 6 Portable Bluetooth Speaker Waterproof',
                'price' => 5999.00,
                'original_price' => 7499.00,
                'discount' => 0.20,
                'rating' => 4.7,
                'review_count' => 2341,
                'seller_rating' => 4.8,
                'sales' => 15000,
                'image' => 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/jbl-speaker',
            ],
            // Fashion
            [
                'id' => 'LZ-1005',
                'title' => 'Nike Air Force 1 07 White Sneakers Original',
                'price' => 5495.00,
                'original_price' => 5795.00,
                'discount' => 0.05,
                'rating' => 4.8,
                'review_count' => 4521,
                'seller_rating' => 4.9,
                'sales' => 32000,
                'image' => 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/nike-air-force',
            ],
            [
                'id' => 'LZ-1006',
                'title' => 'Adidas Ultraboost Running Shoes Men',
                'price' => 7999.00,
                'original_price' => 9500.00,
                'discount' => 0.16,
                'rating' => 4.7,
                'review_count' => 2187,
                'seller_rating' => 4.8,
                'sales' => 18000,
                'image' => 'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/adidas-ultraboost',
            ],
            [
                'id' => 'LZ-1007',
                'title' => 'Ray-Ban Aviator Classic Sunglasses Gold Frame',
                'price' => 7450.00,
                'original_price' => 8950.00,
                'discount' => 0.17,
                'rating' => 4.6,
                'review_count' => 987,
                'seller_rating' => 4.7,
                'sales' => 5600,
                'image' => 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/rayban-aviator',
            ],
            // Home & Living
            [
                'id' => 'LZ-1008',
                'title' => 'Dyson V12 Detect Slim Cordless Vacuum Cleaner',
                'price' => 34999.00,
                'original_price' => 39999.00,
                'discount' => 0.13,
                'rating' => 4.9,
                'review_count' => 654,
                'seller_rating' => 4.9,
                'sales' => 3200,
                'image' => 'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/dyson-vacuum',
            ],
            [
                'id' => 'LZ-1009',
                'title' => 'Instant Pot Duo 7-in-1 Electric Pressure Cooker 6Qt',
                'price' => 4999.00,
                'original_price' => 6499.00,
                'discount' => 0.23,
                'rating' => 4.8,
                'review_count' => 3421,
                'seller_rating' => 4.8,
                'sales' => 22000,
                'image' => 'https://images.unsplash.com/photo-1585515320310-259814833e62?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/instant-pot',
            ],
            [
                'id' => 'LZ-1010',
                'title' => 'Philips Air Fryer XXL Premium HD9861 Digital',
                'price' => 12999.00,
                'original_price' => 15999.00,
                'discount' => 0.19,
                'rating' => 4.8,
                'review_count' => 1876,
                'seller_rating' => 4.9,
                'sales' => 9800,
                'image' => 'https://images.unsplash.com/photo-1626509653291-18d9a934b9db?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/philips-airfryer',
            ],
            // Gaming
            [
                'id' => 'LZ-1011',
                'title' => 'PlayStation 5 DualSense Wireless Controller',
                'price' => 3990.00,
                'original_price' => 4290.00,
                'discount' => 0.07,
                'rating' => 4.9,
                'review_count' => 2543,
                'seller_rating' => 4.9,
                'sales' => 28000,
                'image' => 'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/ps5-controller',
            ],
            [
                'id' => 'LZ-1012',
                'title' => 'Logitech G Pro X Gaming Headset with Blue Voice',
                'price' => 6495.00,
                'original_price' => 7995.00,
                'discount' => 0.19,
                'rating' => 4.7,
                'review_count' => 1234,
                'seller_rating' => 4.8,
                'sales' => 8900,
                'image' => 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/logitech-headset',
            ],
            // Beauty
            [
                'id' => 'LZ-1013',
                'title' => 'Estee Lauder Advanced Night Repair Serum 50ml',
                'price' => 5499.00,
                'original_price' => 6500.00,
                'discount' => 0.15,
                'rating' => 4.9,
                'review_count' => 4532,
                'seller_rating' => 4.9,
                'sales' => 35000,
                'image' => 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/estee-lauder-serum',
            ],
            [
                'id' => 'LZ-1014',
                'title' => 'MAC Lipstick Matte Ruby Woo 3g Original',
                'price' => 1150.00,
                'original_price' => 1350.00,
                'discount' => 0.15,
                'rating' => 4.8,
                'review_count' => 6789,
                'seller_rating' => 4.9,
                'sales' => 52000,
                'image' => 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/mac-lipstick',
            ],
            [
                'id' => 'LZ-1015',
                'title' => 'Olaplex No. 3 Hair Perfector Treatment 100ml',
                'price' => 1899.00,
                'original_price' => 2299.00,
                'discount' => 0.17,
                'rating' => 4.8,
                'review_count' => 2341,
                'seller_rating' => 4.8,
                'sales' => 18000,
                'image' => 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=300&h=300&fit=crop',
                'url' => 'https://www.lazada.com.ph/products/olaplex-treatment',
            ],
        ];

        $products = $this->expandProducts($baseProducts, 100, 'LZ', 1101);

        // Add platform and affiliate URL to all products
        $products = array_map(function (array $product) {
            $product['platform'] = 'lazada';
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
                $products = $this->expandProducts($baseProducts, 100, 'LZ', 1101);
                return array_map(function (array $product) {
                    $product['platform'] = 'lazada';
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

            $factor = 0.86 + (($i % 19) / 50); // 0.86..1.24
            $basePrice = (float)($template['price'] ?? 0);
            $price = round($basePrice * $factor, 2);

            $baseDiscount = (float)($template['discount'] ?? 0.15);
            $delta = (($i % 5) - 2) * 0.015; // -0.03..+0.03
            $discount = min(0.70, max(0.03, $baseDiscount + $delta));
            $originalPrice = round($price / (1 - $discount), 2);

            $baseRating = (float)($template['rating'] ?? 4.6);
            $ratingDelta = (($i % 7) - 3) * 0.05; // -0.15..+0.15
            $rating = min(5.0, max(3.6, round($baseRating + $ratingDelta, 1)));

            $baseReviews = (int)($template['review_count'] ?? 200);
            $reviewCount = max(0, $baseReviews + ($i * 29));

            $url = (string)($template['url'] ?? '');
            $glue = str_contains($url, '?') ? '&' : '?';
            $url = $url !== '' ? $url . $glue . 'mock_id=' . $id : 'https://www.lazada.com.ph/products/mock?mock_id=' . $id;

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
