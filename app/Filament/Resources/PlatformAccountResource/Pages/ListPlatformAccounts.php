<?php

namespace App\Filament\Resources\PlatformAccountResource\Pages;

use App\Filament\Resources\PlatformAccountResource;
use Filament\Resources\Pages\ListRecords;
use Filament\Actions;

class ListPlatformAccounts extends ListRecords
{
    protected static string $resource = PlatformAccountResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
