<?php

namespace App\Filament\Pages;

use App\Filament\Widgets\OverviewStats;
use App\Filament\Widgets\CommissionStats;
use App\Filament\Widgets\ProductsChart;
use App\Filament\Widgets\LatestProducts;
use Filament\Pages\Dashboard as BaseDashboard;

class Dashboard extends BaseDashboard
{
    protected static ?string $navigationIcon = 'heroicon-o-home';
    
    protected static string $view = 'filament.pages.dashboard';

    public function getWidgets(): array
    {
        return [
            OverviewStats::class,
            CommissionStats::class,
            ProductsChart::class,
            LatestProducts::class,
        ];
    }

    public function getColumns(): int | string | array
    {
        return 2;
    }
}
