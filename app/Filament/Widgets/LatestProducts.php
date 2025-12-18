<?php

namespace App\Filament\Widgets;

use App\Models\Product;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LatestProducts extends BaseWidget
{
    protected static ?int $sort = 3;
    protected int | string | array $columnSpan = 'full';
    protected static ?string $heading = 'Latest Products';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Product::query()
                    ->with('listings.platformAccount')
                    ->latest()
                    ->limit(5)
            )
            ->columns([
                Tables\Columns\ImageColumn::make('main_image')
                    ->label('Image')
                    ->circular()
                    ->defaultImageUrl(fn () => 'https://ui-avatars.com/api/?name=P&color=7F9CF5&background=EBF4FF'),
                
                Tables\Columns\TextColumn::make('title')
                    ->searchable()
                    ->sortable()
                    ->limit(40)
                    ->wrap(),
                
                Tables\Columns\TextColumn::make('sku')
                    ->label('SKU')
                    ->badge()
                    ->color('gray')
                    ->searchable(),
                
                Tables\Columns\TextColumn::make('cost_price')
                    ->label('Cost')
                    ->money('PHP')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('desired_margin')
                    ->label('Margin')
                    ->suffix('%')
                    ->badge()
                    ->color('success'),
                
                Tables\Columns\TextColumn::make('listings_count')
                    ->label('Listings')
                    ->counts('listings')
                    ->badge()
                    ->color('info'),
                
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime('M j, Y')
                    ->sortable()
                    ->label('Added'),
            ])
            ->defaultSort('created_at', 'desc');
    }
}
