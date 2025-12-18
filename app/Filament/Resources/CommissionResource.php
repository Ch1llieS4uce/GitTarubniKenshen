<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CommissionResource\Pages;
use App\Models\Commission;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class CommissionResource extends Resource
{
    protected static ?string $model = Commission::class;

    protected static ?string $navigationIcon = 'heroicon-o-currency-dollar';
    protected static ?string $navigationGroup = 'Finance';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Select::make('user_id')
                ->relationship('user', 'name')
                ->required()
                ->searchable(),
            Forms\Components\Select::make('platform')
                ->options([
                    'shopee' => 'Shopee',
                    'lazada' => 'Lazada',
                    'tiktok' => 'TikTok',
                ])
                ->required(),
            Forms\Components\TextInput::make('platform_product_id')
                ->label('Platform Product ID')
                ->maxLength(255)
                ->nullable(),
            Forms\Components\TextInput::make('order_reference')
                ->maxLength(255)
                ->nullable(),
            Forms\Components\TextInput::make('commission_amount')
                ->numeric()
                ->required(),
            Forms\Components\TextInput::make('currency')
                ->default('PHP')
                ->maxLength(10)
                ->required(),
            Forms\Components\Select::make('status')
                ->options([
                    'pending' => 'Pending',
                    'approved' => 'Approved',
                    'paid' => 'Paid',
                ])
                ->default('pending')
                ->required(),
            Forms\Components\DateTimePicker::make('occurred_at')
                ->label('Occurred At')
                ->nullable(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')->label('User')->searchable(),
                Tables\Columns\TextColumn::make('platform')->badge(),
                Tables\Columns\TextColumn::make('order_reference')->sortable()->searchable(),
                Tables\Columns\TextColumn::make('commission_amount')->money('PHP')->sortable(),
                Tables\Columns\BadgeColumn::make('status')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'paid',
                        'primary' => 'approved',
                    ]),
                Tables\Columns\TextColumn::make('occurred_at')->dateTime()->sortable(),
                Tables\Columns\TextColumn::make('created_at')->dateTime()->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('platform')->options([
                    'shopee' => 'Shopee',
                    'lazada' => 'Lazada',
                    'tiktok' => 'TikTok',
                ]),
                Tables\Filters\SelectFilter::make('status')->options([
                    'pending' => 'Pending',
                    'approved' => 'Approved',
                    'paid' => 'Paid',
                ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListCommissions::route('/'),
            'create' => Pages\CreateCommission::route('/create'),
            'edit' => Pages\EditCommission::route('/{record}/edit'),
        ];
    }
}
