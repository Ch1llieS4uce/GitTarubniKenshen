<?php

namespace App\Filament\Widgets;

use App\Models\Listing;
use App\Models\PlatformAccount;
use Filament\Widgets\ChartWidget;

class ProductsChart extends ChartWidget
{
    protected static ?string $heading = 'Listings by Platform';
    protected static ?int $sort = 2;
    protected int | string | array $columnSpan = 'full';

    protected function getData(): array
    {
        $platforms = ['shopee', 'lazada', 'tiktok'];
        $data = [];
        $labels = [];

        foreach ($platforms as $platform) {
            // Count listings through platform accounts
            $count = Listing::whereHas('platformAccount', function ($query) use ($platform) {
                $query->where('platform', $platform);
            })->count();
            
            $data[] = $count;
            $labels[] = ucfirst($platform);
        }

        return [
            'datasets' => [
                [
                    'label' => 'Listings',
                    'data' => $data,
                    'backgroundColor' => [
                        'rgba(82, 227, 255, 0.7)',  // Shopee cyan
                        'rgba(255, 168, 1, 0.7)',   // Lazada orange
                        'rgba(253, 46, 99, 0.7)',   // TikTok pink
                    ],
                    'borderColor' => [
                        'rgb(82, 227, 255)',
                        'rgb(255, 168, 1)',
                        'rgb(253, 46, 99)',
                    ],
                    'borderWidth' => 2,
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'doughnut';
    }

    protected function getOptions(): array
    {
        return [
            'plugins' => [
                'legend' => [
                    'display' => true,
                    'position' => 'bottom',
                ],
            ],
        ];
    }
}
