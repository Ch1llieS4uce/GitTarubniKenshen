<?php

namespace App\Console;

use App\Jobs\SyncPlatformProductsJob;
use App\Models\PlatformAccount;
use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;
use Illuminate\Support\Facades\Log;

class Kernel extends ConsoleKernel
{
    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }

    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        $schedule->call(function (): void {
            try {
                PlatformAccount::query()
                    ->select('id')
                    ->orderBy('id')
                    ->chunkById(100, function ($accounts): void {
                        foreach ($accounts as $account) {
                            SyncPlatformProductsJob::dispatch((int) $account->id);
                        }
                    });
            } catch (\Throwable $e) {
                Log::error('Auto sync dispatch failed', ['error' => $e->getMessage()]);
            }
        })->hourly()->withoutOverlapping();

        if (config('sanctum.expiration')) {
            $schedule->command('sanctum:prune-expired')->daily()->withoutOverlapping();
        }
    }
}
