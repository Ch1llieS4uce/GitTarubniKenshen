<?php

namespace App\Services;

/**
 * Mock Product Generator
 * 
 * Generates 2000 products per platform (Lazada, Shopee, TikTokShop)
 * following the exact fixed JSON schema.
 */
class MockProductGenerator
{
    private const PLATFORMS = ['lazada', 'shopee', 'tiktokshop'];
    private const PRODUCTS_PER_PLATFORM = 2000;

    /**
     * Product templates for generating realistic mock data
     */
    private array $productTemplates = [
        ['name' => 'Apple AirPods Pro 2nd Generation', 'category' => 'Electronics', 'base_price' => 14990, 'image_seed' => 'airpods'],
        ['name' => 'Samsung Galaxy Buds2 Pro', 'category' => 'Electronics', 'base_price' => 9990, 'image_seed' => 'galaxybuds'],
        ['name' => 'Xiaomi Redmi Note 13 Pro 5G', 'category' => 'Mobile Phones', 'base_price' => 15990, 'image_seed' => 'redmi13'],
        ['name' => 'Anker PowerCore 20000mAh Power Bank', 'category' => 'Electronics', 'base_price' => 2499, 'image_seed' => 'anker'],
        ['name' => 'JBL Flip 6 Portable Bluetooth Speaker', 'category' => 'Electronics', 'base_price' => 6995, 'image_seed' => 'jblflip'],
        ['name' => 'Logitech G Pro X Superlight Mouse', 'category' => 'Computer Accessories', 'base_price' => 7495, 'image_seed' => 'logitechg'],
        ['name' => 'Sony WH-1000XM5 Headphones', 'category' => 'Electronics', 'base_price' => 19990, 'image_seed' => 'sonywh'],
        ['name' => 'Nintendo Switch OLED Model', 'category' => 'Gaming', 'base_price' => 17995, 'image_seed' => 'switcholed'],
        ['name' => 'Kindle Paperwhite 11th Gen', 'category' => 'Electronics', 'base_price' => 7490, 'image_seed' => 'kindle'],
        ['name' => 'Dyson V15 Detect Vacuum', 'category' => 'Home Appliances', 'base_price' => 34990, 'image_seed' => 'dyson'],
        ['name' => 'Apple Watch Series 9 GPS 45mm', 'category' => 'Wearables', 'base_price' => 24990, 'image_seed' => 'applewatch'],
        ['name' => 'Bose QuietComfort Ultra Earbuds', 'category' => 'Electronics', 'base_price' => 17990, 'image_seed' => 'boseqc'],
        ['name' => 'Samsung 65" QLED 4K Smart TV', 'category' => 'Electronics', 'base_price' => 54990, 'image_seed' => 'samsungtv'],
        ['name' => 'DJI Mini 3 Pro Drone', 'category' => 'Electronics', 'base_price' => 42990, 'image_seed' => 'djimini'],
        ['name' => 'GoPro HERO12 Black', 'category' => 'Electronics', 'base_price' => 24990, 'image_seed' => 'gopro'],
        ['name' => 'iPhone 15 Pro Max 256GB', 'category' => 'Mobile Phones', 'base_price' => 74990, 'image_seed' => 'iphone15'],
        ['name' => 'MacBook Air M3 15-inch', 'category' => 'Computers', 'base_price' => 79990, 'image_seed' => 'macbookair'],
        ['name' => 'iPad Pro 12.9 M2', 'category' => 'Tablets', 'base_price' => 69990, 'image_seed' => 'ipadpro'],
        ['name' => 'Samsung Galaxy S24 Ultra', 'category' => 'Mobile Phones', 'base_price' => 69990, 'image_seed' => 'galaxys24'],
        ['name' => 'ASUS ROG Zephyrus G14', 'category' => 'Computers', 'base_price' => 89990, 'image_seed' => 'rogzephyrus'],
        ['name' => 'Razer BlackWidow V4 Pro Keyboard', 'category' => 'Computer Accessories', 'base_price' => 12990, 'image_seed' => 'razerblackwidow'],
        ['name' => 'LG C3 55" OLED TV', 'category' => 'Electronics', 'base_price' => 74990, 'image_seed' => 'lgc3'],
        ['name' => 'Fitbit Charge 6', 'category' => 'Wearables', 'base_price' => 8990, 'image_seed' => 'fitbit'],
        ['name' => 'Canon EOS R6 Mark II', 'category' => 'Cameras', 'base_price' => 139990, 'image_seed' => 'canonr6'],
        ['name' => 'Sony Alpha 7 IV', 'category' => 'Cameras', 'base_price' => 129990, 'image_seed' => 'sonya7'],
        ['name' => 'Philips Hue Starter Kit', 'category' => 'Smart Home', 'base_price' => 7990, 'image_seed' => 'philipshue'],
        ['name' => 'Roomba j7+ Robot Vacuum', 'category' => 'Home Appliances', 'base_price' => 44990, 'image_seed' => 'roomba'],
        ['name' => 'Instant Pot Duo 7-in-1', 'category' => 'Kitchen Appliances', 'base_price' => 5990, 'image_seed' => 'instantpot'],
        ['name' => 'Ninja Foodi Air Fryer', 'category' => 'Kitchen Appliances', 'base_price' => 8990, 'image_seed' => 'ninjafoodi'],
        ['name' => 'Nespresso Vertuo Next', 'category' => 'Kitchen Appliances', 'base_price' => 9990, 'image_seed' => 'nespresso'],
        ['name' => 'Breville Barista Express', 'category' => 'Kitchen Appliances', 'base_price' => 34990, 'image_seed' => 'breville'],
        ['name' => 'Herman Miller Aeron Chair', 'category' => 'Furniture', 'base_price' => 89990, 'image_seed' => 'aeron'],
        ['name' => 'Secretlab Titan Evo', 'category' => 'Furniture', 'base_price' => 24990, 'image_seed' => 'secretlab'],
        ['name' => 'LG UltraGear 27" Gaming Monitor', 'category' => 'Computer Accessories', 'base_price' => 19990, 'image_seed' => 'lgultragear'],
        ['name' => 'Samsung Odyssey G9 49"', 'category' => 'Computer Accessories', 'base_price' => 64990, 'image_seed' => 'odysseyg9'],
        ['name' => 'Keychron K8 Pro Keyboard', 'category' => 'Computer Accessories', 'base_price' => 5990, 'image_seed' => 'keychron'],
        ['name' => 'Elgato Stream Deck MK.2', 'category' => 'Computer Accessories', 'base_price' => 7990, 'image_seed' => 'streamdeck'],
        ['name' => 'Blue Yeti X Microphone', 'category' => 'Electronics', 'base_price' => 8990, 'image_seed' => 'blueyeti'],
        ['name' => 'Shure SM7B Microphone', 'category' => 'Electronics', 'base_price' => 24990, 'image_seed' => 'shuresm7b'],
        ['name' => 'Audio-Technica ATH-M50x', 'category' => 'Electronics', 'base_price' => 7990, 'image_seed' => 'athm50x'],
        ['name' => 'Sennheiser HD 660S', 'category' => 'Electronics', 'base_price' => 24990, 'image_seed' => 'sennheiser660'],
        ['name' => 'Marshall Stanmore III Speaker', 'category' => 'Electronics', 'base_price' => 24990, 'image_seed' => 'marshall'],
        ['name' => 'Sonos One SL', 'category' => 'Electronics', 'base_price' => 11990, 'image_seed' => 'sonosone'],
        ['name' => 'Google Nest Hub Max', 'category' => 'Smart Home', 'base_price' => 14990, 'image_seed' => 'nesthub'],
        ['name' => 'Amazon Echo Show 10', 'category' => 'Smart Home', 'base_price' => 14990, 'image_seed' => 'echoshow'],
        ['name' => 'Ring Video Doorbell Pro 2', 'category' => 'Smart Home', 'base_price' => 14990, 'image_seed' => 'ringdoorbell'],
        ['name' => 'Arlo Pro 4 Camera', 'category' => 'Smart Home', 'base_price' => 11990, 'image_seed' => 'arlopro'],
        ['name' => 'Nanoleaf Shapes Hexagons', 'category' => 'Smart Home', 'base_price' => 11990, 'image_seed' => 'nanoleaf'],
        ['name' => 'Govee LED Strip Lights', 'category' => 'Smart Home', 'base_price' => 1990, 'image_seed' => 'govee'],
        ['name' => 'Theragun Prime Massage Gun', 'category' => 'Health & Fitness', 'base_price' => 17990, 'image_seed' => 'theragun'],
    ];

    /**
     * Generate all products (2000 per platform = 6000 total)
     */
    public function generateAll(): array
    {
        $allProducts = [];
        $groupCount = ceil(self::PRODUCTS_PER_PLATFORM / 1); // Each group has 3 products (one per platform)
        
        for ($groupIndex = 0; $groupIndex < $groupCount; $groupIndex++) {
            $template = $this->productTemplates[$groupIndex % count($this->productTemplates)];
            $groupId = $this->generateGroupId($template['name'], $groupIndex);
            
            foreach (self::PLATFORMS as $platform) {
                $product = $this->generateProduct($template, $platform, $groupId, $groupIndex);
                $allProducts[] = $product;
            }
        }

        return $allProducts;
    }

    /**
     * Generate products for a specific platform
     */
    public function generateForPlatform(string $platform, int $limit = 2000, int $offset = 0): array
    {
        $products = [];
        $templateCount = count($this->productTemplates);

        for ($i = $offset; $i < $offset + $limit; $i++) {
            $template = $this->productTemplates[$i % $templateCount];
            $groupId = $this->generateGroupId($template['name'], $i);
            $products[] = $this->generateProduct($template, $platform, $groupId, $i);
        }

        return $products;
    }

    /**
     * Generate a single product following the exact fixed schema
     */
    private function generateProduct(array $template, string $platform, string $groupId, int $index): array
    {
        $seed = crc32($groupId . $platform);
        mt_srand($seed);

        // Price variation per platform (-15% to +20%)
        $priceVariation = (mt_rand(-15, 20) / 100);
        $price = round($template['base_price'] * (1 + $priceVariation), 2);
        
        // Make one platform clearly cheaper for demo effect
        if ($platform === self::PLATFORMS[$index % 3]) {
            $price = round($template['base_price'] * 0.85, 2);
        }

        $originalPrice = round($price * (1 + (mt_rand(10, 35) / 100)), 2);
        $discountPct = round((($originalPrice - $price) / $originalPrice) * 100, 0);
        $rating = round(4.0 + (mt_rand(0, 10) / 10), 1);
        $reviewCount = mt_rand(50, 10000);
        $sales = mt_rand(100, 50000);

        // AI recommendation calculations
        $competitorAvg = round($template['base_price'] * 1.05, 2);
        $minPrice = round($template['base_price'] * 0.80, 2);
        $demandFactor = round(0.5 + (mt_rand(0, 50) / 100), 2);
        $alpha = 0.65;
        $beta = 0.35;
        $gamma = 0.05;
        
        $recommendedPrice = round(
            ($alpha * $competitorAvg) + 
            ($beta * $minPrice) + 
            ($gamma * $competitorAvg * $demandFactor),
            2
        );
        
        $confidence = round(0.75 + (mt_rand(0, 20) / 100), 2);
        $recommendedSavings = max(0, round($price - $recommendedPrice, 2));

        $productId = $this->generateProductId($platform, $groupId, $index);

        return [
            'id' => $productId,
            'group_id' => $groupId,
            'platform' => $platform,
            'title' => $this->generateTitle($template['name'], $platform, $index),
            'category' => $template['category'],
            'price' => $price,
            'original_price' => $originalPrice,
            'discount_pct' => $discountPct,
            'rating' => $rating,
            'review_count' => $reviewCount,
            'sales' => $sales,

            'image_url' => $this->generateImageUrl($template['image_seed'], 400),
            'thumbnail_url' => $this->generateImageUrl($template['image_seed'], 150),
            'url' => $this->generateProductUrl($platform, $productId),

            'ai_recommendation' => [
                'recommended_price' => $recommendedPrice,
                'confidence' => $confidence,
                'recommended_savings' => $recommendedSavings,
                'model_version' => 'v2.1.0',
                'explain' => [
                    'competitor_avg' => $competitorAvg,
                    'min_price' => $minPrice,
                    'demand_factor' => $demandFactor,
                    'alpha' => $alpha,
                    'beta' => $beta,
                    'gamma' => $gamma,
                    'clamp_applied' => $recommendedPrice < $minPrice,
                    'reason' => $this->generateReason($platform, $price, $recommendedPrice),
                ],
            ],

            'meta' => [
                'data_source' => 'mock_api',
                'last_updated' => now()->toIso8601String(),
                'is_dynamic' => true,
            ],
        ];
    }

    /**
     * Generate group ID for cross-platform matching
     */
    private function generateGroupId(string $name, int $index): string
    {
        $slug = strtolower(preg_replace('/[^a-zA-Z0-9]+/', '-', $name));
        $slug = trim($slug, '-');
        $variant = floor($index / count($this->productTemplates));
        return $variant > 0 ? "{$slug}-v{$variant}" : $slug;
    }

    /**
     * Generate unique product ID
     */
    private function generateProductId(string $platform, string $groupId, int $index): string
    {
        $prefix = strtoupper(substr($platform, 0, 3));
        $hash = substr(md5($groupId . $platform . $index), 0, 8);
        return "{$prefix}-{$hash}";
    }

    /**
     * Generate platform-specific title variation
     */
    private function generateTitle(string $baseName, string $platform, int $index): string
    {
        $suffixes = [
            'lazada' => ['[Official Store]', '[Authentic]', '[Fast Delivery]'],
            'shopee' => ['🔥 Hot Deal', '✨ Best Seller', '💯 Original'],
            'tiktokshop' => ['| TikTok Exclusive', '| Viral Product', '| Trending'],
        ];

        $variant = floor($index / count($this->productTemplates));
        if ($variant > 0) {
            $baseName .= " - Variant {$variant}";
        }

        $suffix = $suffixes[$platform][$index % 3] ?? '';
        return trim("{$baseName} {$suffix}");
    }

    /**
     * Generate image URL using picsum.photos
     */
    private function generateImageUrl(string $seed, int $size): string
    {
        return "https://picsum.photos/seed/{$seed}/{$size}/{$size}";
    }

    /**
     * Generate real platform product URL
     */
    private function generateProductUrl(string $platform, string $productId): string
    {
        return match ($platform) {
            'lazada' => "https://www.lazada.com.ph/products/{$productId}.html",
            'shopee' => "https://shopee.ph/product/{$productId}",
            'tiktokshop' => "https://shop.tiktok.com/view/product/{$productId}",
            default => "https://example.com/product/{$productId}",
        };
    }

    /**
     * Generate AI recommendation reason
     */
    private function generateReason(string $platform, float $price, float $recommendedPrice): string
    {
        $platformName = match ($platform) {
            'lazada' => 'Lazada',
            'shopee' => 'Shopee',
            'tiktokshop' => 'TikTok Shop',
            default => ucfirst($platform),
        };

        if ($price <= $recommendedPrice) {
            return "{$platformName} offers a competitive price below the AI-recommended threshold.";
        }

        $diff = round($price - $recommendedPrice, 2);
        return "Consider negotiating ₱{$diff} lower on {$platformName} to match AI recommendation.";
    }
}
