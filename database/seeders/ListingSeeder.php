<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Listing;
use App\Models\Product;
use App\Models\PlatformAccount;

class ListingSeeder extends Seeder
{
    public function run()
    {
        $product = Product::first();
        $account = PlatformAccount::first();

        if ($product && $account) {
            Listing::create([
                'product_id' => $product->id,
                'platform_account_id' => $account->id,
                'platform_product_id' => 'P_DEMO_1',
                'price' => 199.00,
                'stock' => 10,
                'status' => 'active',
            ]);
        }
    }
}
