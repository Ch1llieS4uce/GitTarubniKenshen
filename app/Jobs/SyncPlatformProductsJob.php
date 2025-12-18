<?php

namespace App\Jobs;

use App\Services\PlatformSyncService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SyncPlatformProductsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $platformAccountId;
    public string $jobType;

    public function __construct(int $platformAccountId, string $jobType = 'products')
    {
        $this->platformAccountId = $platformAccountId;
        $this->jobType = $jobType;
    }

    public function handle(PlatformSyncService $syncService): void
    {
        $syncService->sync($this->platformAccountId, $this->jobType);
    }
}
