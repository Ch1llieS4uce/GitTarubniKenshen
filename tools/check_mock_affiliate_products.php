<?php

require __DIR__ . '/../app/Services/Affiliates/Contracts/ProductSearchClient.php';
require __DIR__ . '/../app/Services/Affiliates/ShopeeClient.php';
require __DIR__ . '/../app/Services/Affiliates/LazadaClient.php';
require __DIR__ . '/../app/Services/Affiliates/TikTokShopClient.php';

use App\Services\Affiliates\LazadaClient;
use App\Services\Affiliates\ShopeeClient;
use App\Services\Affiliates\TikTokShopClient;

$clients = [
    'shopee' => new ShopeeClient(),
    'lazada' => new LazadaClient(),
    'tiktok' => new TikTokShopClient(),
];

foreach ($clients as $name => $client) {
    $all = $client->search('', 1, 200);
    $page1 = $client->search('', 1, 20);
    $page2 = $client->search('', 2, 20);
    $wireless = $client->search('Wireless', 1, 200);

    echo strtoupper($name) . ' total=' . count($all) . ' page1=' . count($page1) . ' page2=' . count($page2) . ' query(Wireless)=' . count($wireless) . PHP_EOL;

    if (count($all) !== 100) {
        fwrite(STDERR, "FAILED: {$name} expected 100 products\n");
        exit(1);
    }
    if (count($page1) > 20 || count($page2) > 20) {
        fwrite(STDERR, "FAILED: {$name} pagination exceeded pageSize=20\n");
        exit(1);
    }
}

echo "OK\n";

