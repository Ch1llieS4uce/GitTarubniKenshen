<?php

namespace App\Services\Affiliates;

use App\Services\Affiliates\Contracts\ProductSearchClient;
use InvalidArgumentException;

class AffiliateClientFactory
{
    public function make(string $platform): ProductSearchClient
    {
        return match ($platform) {
            'lazada' => app(LazadaClient::class),
            'shopee' => app(ShopeeClient::class),
            'tiktok' => app(TikTokShopClient::class),
            default => throw new InvalidArgumentException("Unsupported platform: {$platform}"),
        };
    }
}
