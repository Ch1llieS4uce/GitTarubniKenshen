<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PlatformAccountResource\Pages;
use App\Models\PlatformAccount;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class PlatformAccountResource extends Resource
{
    protected static ?string $model = PlatformAccount::class;

    protected static ?string $navigationIcon = 'heroicon-o-globe-alt';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('user_id')
                    ->relationship('user', 'name')
                    ->required(),
                Forms\Components\Select::make('platform')
                    ->options([
                        'shopee' => 'Shopee',
                        'lazada' => 'Lazada',
                        'tiktok' => 'TikTok',
                    ])
                    ->required(),
                Forms\Components\TextInput::make('account_name')
                    ->required()
                    ->maxLength(255),
                Forms\Components\Textarea::make('access_token')
                    ->columnSpanFull(),
                Forms\Components\Textarea::make('refresh_token')
                    ->columnSpanFull(),
                Forms\Components\KeyValue::make('additional_data')
                    ->nullable()
                    ->columnSpanFull(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->searchable(),
                Tables\Columns\TextColumn::make('platform')
                    ->badge(),
                Tables\Columns\TextColumn::make('account_name')
                    ->searchable(),
                Tables\Columns\TextColumn::make('last_synced_at')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('platform')
                    ->options([
                        'shopee' => 'Shopee',
                        'lazada' => 'Lazada',
                        'tiktok' => 'TikTok',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            // 
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPlatformAccounts::route('/'),
            'create' => Pages\CreatePlatformAccount::route('/create'),
            'edit' => Pages\EditPlatformAccount::route('/{record}/edit'),
        ];
    }
}
