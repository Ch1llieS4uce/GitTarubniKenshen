<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\PlatformAccount;
use App\Models\User;

class PlatformAccountSeeder extends Seeder
{
    public function run()
    {
        $user = User::where('role','seller')->first() ?? User::first();

        PlatformAccount::create([
            'user_id' => $user->id,
            'platform' => 'shopee',
            'account_name' => 'Demo Shopee',
            'additional_data' => [],
        ]);
    }
}
