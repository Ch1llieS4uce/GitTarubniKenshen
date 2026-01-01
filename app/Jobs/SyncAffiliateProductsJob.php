<?php

namespace App\Jobs;

use App\Services\Affiliates\AffiliateProductService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class SyncAffiliateProductsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $timeout = 600; // 10 minutes
    public int $backoff = 60;

    /**
     * Create a new job instance.
     */
    public function __construct(
        public ?string $platform = null,
        public int $maxProducts = 2000
    ) {}

    /**
     * Execute the job.
     */
    public function handle(AffiliateProductService $service): void
    {
        Log::info('Starting affiliate products sync job', [
            'platform' => $this->platform ?? 'all',
            'max_products' => $this->maxProducts,
        ]);

        try {
            if ($this->platform) {
                $result = $service->syncPlatformProducts($this->platform, $this->maxProducts);
                Log::info('Single platform sync completed', $result);
            } else {
                $results = $service->syncAllPlatforms($this->maxProducts);
                Log::info('All platforms sync completed', ['results' => $results]);
            }
        } catch (\Throwable $e) {
            Log::error('Affiliate products sync failed', [
                'platform' => $this->platform ?? 'all',
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            throw $e;
        }
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        Log::error('Affiliate products sync job failed permanently', [
            'platform' => $this->platform ?? 'all',
            'error' => $exception->getMessage(),
        ]);
    }
}
