<?php

namespace App\Filament\Widgets;

use App\Models\Commission;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Carbon;

class CommissionStats extends BaseWidget
{
    protected static ?string $pollingInterval = '30s';

    protected function getStats(): array
    {
        $total = Commission::sum('commission_amount');
        $pending = Commission::where('status', 'pending')->sum('commission_amount');
        $paid = Commission::where('status', 'paid')->sum('commission_amount');
        
        // Calculate this month's data
        $thisMonth = Commission::whereMonth('created_at', Carbon::now()->month)
            ->sum('commission_amount');
        $lastMonth = Commission::whereMonth('created_at', Carbon::now()->subMonth()->month)
            ->sum('commission_amount');
        
        $monthlyChange = $lastMonth > 0 
            ? (($thisMonth - $lastMonth) / $lastMonth) * 100 
            : 0;
        
        $changeDescription = $monthlyChange >= 0 
            ? number_format($monthlyChange, 1) . '% increase from last month'
            : number_format(abs($monthlyChange), 1) . '% decrease from last month';

        return [
            Stat::make('Total Commissions', '₱' . number_format((float)$total, 2))
                ->description($changeDescription)
                ->descriptionIcon($monthlyChange >= 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-arrow-trending-down')
                ->color($monthlyChange >= 0 ? 'success' : 'danger')
                ->chart($this->getMonthlyTrend()),
            Stat::make('Pending Commissions', '₱' . number_format((float)$pending, 2))
                ->description('Awaiting approval/payout')
                ->descriptionIcon('heroicon-m-clock')
                ->color('warning'),
            Stat::make('Paid Commissions', '₱' . number_format((float)$paid, 2))
                ->description('Successfully disbursed')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('success'),
        ];
    }

    protected function getMonthlyTrend(): array
    {
        $data = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::now()->subMonths($i);
            $amount = Commission::whereYear('created_at', $date->year)
                ->whereMonth('created_at', $date->month)
                ->sum('commission_amount');
            $data[] = (float)$amount;
        }
        return $data;
    }
}
