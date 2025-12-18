<?php

namespace App\Services;

use App\Models\PlatformAccount;
use App\Models\Listing;
use App\Models\PriceHistory;
use App\Models\Product;
use App\Models\SyncLog;
use App\Services\Affiliates\AffiliateClientFactory;
use Illuminate\Support\Facades\Log;

class PlatformSyncService
{
    public function __construct(private readonly AffiliateClientFactory $affiliateClientFactory)
    {
    }

    /**
     * Sync products for a platform account.
     *
     * @param int $platformAccountId
     * @return void
     */
    public function syncProducts(int $platformAccountId): void
    {
        $this->sync($platformAccountId, 'products');
    }

    public function sync(int $platformAccountId, string $jobType = 'products'): void
    {
        $account = PlatformAccount::find($platformAccountId);

        if (!$account) {
            Log::warning('Platform account not found', ['id' => $platformAccountId]);
            return;
        }

        try {
            $startTime = now();
            $syncLog = SyncLog::create([
                'platform_account_id' => $platformAccountId,
                'job_type' => $jobType,
                'status' => 'running',
                'started_at' => $startTime,
            ]);

            // Fetch external products based on platform
            $externalProducts = $this->fetchFromPlatform($account);

            if (empty($externalProducts)) {
                $syncLog->update([
                    'status' => 'success',
                    'details' => ['message' => 'No products to sync', 'synced_count' => 0],
                    'finished_at' => now(),
                ]);
                return;
            }

            $syncedCount = 0;
            foreach ($externalProducts as $externalProduct) {
                try {
                    $this->syncProductListing($account, $externalProduct);
                    $syncedCount++;
                } catch (\Throwable $e) {
                    Log::error('Failed to sync product', [
                        'platform_id' => $externalProduct['id'] ?? null,
                        'error' => $e->getMessage(),
                    ]);
                }
            }

            $syncLog->update([
                'status' => 'success',
                'details' => [
                    'synced_count' => $syncedCount,
                    'duration_seconds' => now()->diffInSeconds($startTime),
                ],
                'finished_at' => now(),
            ]);

            $account->update(['last_synced_at' => now()]);

            Log::info('Platform sync completed', [
                'account_id' => $platformAccountId,
                'synced_count' => $syncedCount,
            ]);
        } catch (\Throwable $e) {
            Log::error('Platform sync failed', [
                'account_id' => $platformAccountId,
                'error' => $e->getMessage(),
            ]);

            if (isset($syncLog)) {
                $syncLog->update([
                    'status' => 'failed',
                    'details' => ['error' => $e->getMessage()],
                    'finished_at' => now(),
                ]);
            }
        }
    }

    /**
     * Fetch products from external platform API.
     * Implement platform-specific logic here.
     *
     * @param PlatformAccount $account
     * @return array
     */
    protected function fetchFromPlatform(PlatformAccount $account): array
    {
        // Today this uses the built-in sample affiliate clients so you can test end-to-end.
        // Swap this to real platform integrations (OAuth + catalog endpoints) when credentials are available.
        $client = $this->affiliateClientFactory->make($account->platform);
        $raw = $client->search('', 1, 100);

        return array_map(function (array $item) use ($account) {
            return [
                'id' => $item['id'] ?? null,
                'title' => $item['title'] ?? 'Synced Product',
                'sku' => $item['sku'] ?? ($item['id'] ?? 'UNKNOWN'),
                'description' => $item['description'] ?? null,
                'price' => (float)($item['price'] ?? 0),
                'stock' => (int)($item['stock'] ?? 10),
                'platform' => $account->platform,
            ];
        }, array_filter($raw, fn ($x) => is_array($x)));
    }

    /**
     * Sync a single product/listing to database.
     *
     * @param PlatformAccount $account
     * @param array $externalProduct
     * @return void
     */
    protected function syncProductListing(PlatformAccount $account, array $externalProduct): void
    {
        // Find or create product
        $product = Product::firstOrCreate(
            [
                'user_id' => $account->user_id,
                'sku' => $externalProduct['sku'] ?? 'UNKNOWN',
            ],
            [
                'title' => $externalProduct['title'] ?? 'Synced Product',
                'description' => $externalProduct['description'] ?? null,
            ]
        );

        // Find or create listing
        $listing = Listing::firstOrCreate(
            [
                'platform_account_id' => $account->id,
                'platform_product_id' => $externalProduct['id'],
            ],
            [
                'product_id' => $product->id,
                'price' => $externalProduct['price'] ?? 0,
                'stock' => $externalProduct['stock'] ?? 0,
                'status' => 'active',
                'synced_at' => now(),
            ]
        );

        // Update if exists
        if ($listing->wasRecentlyCreated === false) {
            $previousPrice = (float)$listing->price;
            $listing->update([
                'price' => $externalProduct['price'] ?? $listing->price,
                'stock' => $externalProduct['stock'] ?? $listing->stock,
                'synced_at' => now(),
            ]);

            $newPrice = (float)$listing->price;
            if ($newPrice !== $previousPrice) {
                PriceHistory::create([
                    'listing_id' => $listing->id,
                    'price' => $newPrice,
                    'source' => 'platform',
                    'recorded_at' => now(),
                ]);
            }
        } else {
            PriceHistory::create([
                'listing_id' => $listing->id,
                'price' => (float)($listing->price ?? 0),
                'source' => 'platform',
                'recorded_at' => now(),
            ]);
        }
    }
}
