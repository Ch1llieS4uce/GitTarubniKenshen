<?php

namespace App\Filament\Widgets;

use App\Models\Product;
use App\Models\Listing;
use App\Models\User;
use App\Models\PlatformAccount;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class OverviewStats extends BaseWidget
{
    protected static ?int $sort = 1;
    protected static ?string $pollingInterval = '30s';

    protected function getStats(): array
    {
        $totalProducts = Product::count();
        $totalListings = Listing::count();
        $activeListings = Listing::where('status', 'active')->count();
        $totalUsers = User::count();
        $newUsersThisMonth = User::whereMonth('created_at', now()->month)->count();
        $platformAccounts = PlatformAccount::count();

        return [
            Stat::make('Total Products', number_format($totalProducts))
                ->description($totalListings . ' listings across platforms')
                ->descriptionIcon('heroicon-m-cube')
                ->color('info')
                ->chart($this->getProductTrend()),
            
            Stat::make('Total Users', number_format($totalUsers))
                ->description($newUsersThisMonth . ' new this month')
                ->descriptionIcon('heroicon-m-user-group')
                ->color('success')
                ->chart($this->getUserTrend()),
            
            Stat::make('Active Listings', number_format($activeListings))
                ->description($platformAccounts . ' connected accounts')
                ->descriptionIcon('heroicon-m-shopping-bag')
                ->color('warning')
                ->chart($this->getListingTrend()),
        ];
    }

    protected function getProductTrend(): array
    {
        $data = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = Product::whereDate('created_at', $date)->count();
            $data[] = $count;
        }
        return $data;
    }

    protected function getUserTrend(): array
    {
        $data = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = User::whereDate('created_at', $date)->count();
            $data[] = $count;
        }
        return $data;
    }

    protected function getListingTrend(): array
    {
        $data = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = Listing::whereDate('created_at', $date)->count();
            $data[] = $count;
        }
        return $data;
    }
}
