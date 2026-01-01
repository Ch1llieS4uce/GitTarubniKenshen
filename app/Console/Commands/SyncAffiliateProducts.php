<?php

namespace App\Console\Commands;

use App\Jobs\SyncAffiliateProductsJob;
use App\Services\Affiliates\AffiliateProductService;
use Illuminate\Console\Command;

class SyncAffiliateProducts extends Command
{
    protected $signature = 'affiliate:sync 
        {--platform= : Specific platform to sync (lazada, shopee, tiktok). Omit for all.}
        {--max=2000 : Maximum products per platform to sync}
        {--queue : Dispatch as background job instead of running synchronously}';

    protected $description = 'Sync affiliate products from platform APIs to local database cache';

    public function handle(AffiliateProductService $service): int
    {
        $platform = $this->option('platform');
        $max = (int) $this->option('max');
        $useQueue = $this->option('queue');

        if ($platform && !in_array($platform, ['lazada', 'shopee', 'tiktok'])) {
            $this->error("Invalid platform: {$platform}. Use lazada, shopee, or tiktok.");
            return self::FAILURE;
        }

        if ($useQueue) {
            if ($platform) {
                SyncAffiliateProductsJob::dispatch($platform, $max);
                $this->info("Dispatched sync job for {$platform} (max: {$max} products)");
            } else {
                // Dispatch separate jobs for each platform
                foreach (['lazada', 'shopee', 'tiktok'] as $p) {
                    SyncAffiliateProductsJob::dispatch($p, $max);
                    $this->info("Dispatched sync job for {$p} (max: {$max} products)");
                }
            }
            return self::SUCCESS;
        }

        // Synchronous execution
        $this->info('Starting affiliate products sync...');
        $this->newLine();

        if ($platform) {
            $this->syncPlatform($service, $platform, $max);
        } else {
            foreach (['lazada', 'shopee', 'tiktok'] as $p) {
                $this->syncPlatform($service, $p, $max);
                $this->newLine();
            }
        }

        $this->newLine();
        $this->info('Sync completed!');
        
        // Show stats
        $stats = $service->getPlatformStats();
        $this->table(
            ['Platform', 'Cached Products', 'Last Sync'],
            collect($stats)->map(fn($s, $p) => [
                ucfirst($p),
                number_format($s['cached_count']),
                $s['last_sync'] ?? 'Never',
            ])->toArray()
        );

        return self::SUCCESS;
    }

    protected function syncPlatform(AffiliateProductService $service, string $platform, int $max): void
    {
        $this->info("Syncing {$platform}...");
        
        $bar = $this->output->createProgressBar($max);
        $bar->start();

        try {
            $result = $service->syncPlatformProducts($platform, $max);
            $bar->finish();
            $this->newLine();
            $this->info(sprintf(
                '  ✓ %s: %d synced, %d failed',
                ucfirst($platform),
                $result['synced'],
                $result['failed']
            ));
        } catch (\Throwable $e) {
            $bar->finish();
            $this->newLine();
            $this->error("  ✗ {$platform} sync failed: {$e->getMessage()}");
        }
    }
}
