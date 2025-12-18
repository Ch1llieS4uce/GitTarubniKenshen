<?php

namespace App\Services\Affiliates\Contracts;

interface ProductSearchClient
{
    /**
     * Search products on a given platform and return a normalized array.
     */
    public function search(string $query, int $page = 1, int $pageSize = 20): array;

    /**
     * Retrieve a single product by platform product id and return a normalized array.
     */
    public function getProduct(string $platformProductId): array;

    /**
     * Create an affiliate/deep link from a target URL.
     */
    public function createAffiliateLink(string $targetUrl): string;
}
