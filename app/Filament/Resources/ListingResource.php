<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ListingResource\Pages;
use App\Models\Listing;
use Filament\Forms;
use Filament\Tables;
use Filament\Resources\Resource;

class ListingResource extends Resource
{
    protected static ?string $model = Listing::class;
    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';
    protected static ?string $navigationGroup = 'Products & Listings';

    public static function form(Forms\Form $form): Forms\Form
    {
        return $form->schema([
            Forms\Components\Select::make('product_id')
                ->relationship('product', 'title')
                ->required(),

            Forms\Components\Select::make('platform_account_id')
                ->relationship('platformAccount', 'account_name')
                ->required(),

            Forms\Components\TextInput::make('platform_product_id')
                ->label('Platform Product ID')
                ->required(),

            Forms\Components\TextInput::make('price')->numeric()->required(),
            Forms\Components\TextInput::make('stock')->numeric()->required(),
            Forms\Components\Select::make('status')
                ->options([
                    'active' => 'Active',
                    'inactive' => 'Inactive',
                ])->required(),
        ]);
    }

    public static function table(Tables\Table $table): Tables\Table
    {
        return $table->columns([
            Tables\Columns\TextColumn::make('product.title')->label('Product')->searchable(),
            Tables\Columns\TextColumn::make('platformAccount.account_name')->label('Platform')->searchable(),
            Tables\Columns\TextColumn::make('platform_product_id')->label('Platform ID'),
            Tables\Columns\TextColumn::make('price')->sortable(),
            Tables\Columns\TextColumn::make('stock')->sortable(),
            Tables\Columns\TextColumn::make('status'),
            Tables\Columns\TextColumn::make('created_at')->dateTime(),
        ]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListListings::route('/'),
            'create' => Pages\CreateListing::route('/create'),
            'edit'   => Pages\EditListing::route('/{record}/edit'),
        ];
    }
}
