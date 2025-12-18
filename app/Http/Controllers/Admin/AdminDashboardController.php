<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Listing;
use App\Models\PlatformAccount;
use App\Models\Product;
use App\Models\SyncLog;
use App\Models\User;
use Illuminate\Http\Request;

class AdminDashboardController extends Controller
{
    public function index(Request $request)
    {
        return response()->json([
            'users' => [
                'total' => User::count(),
                'sellers' => User::where('role', 'seller')->count(),
                'admins' => User::where('role', 'admin')->count(),
            ],
            'commerce' => [
                'platform_accounts' => PlatformAccount::count(),
                'products' => Product::count(),
                'listings' => Listing::count(),
            ],
            'sync' => [
                'failed_last_24h' => SyncLog::where('status', 'failed')
                    ->where('created_at', '>=', now()->subDay())
                    ->count(),
                'running' => SyncLog::where('status', 'running')->count(),
            ],
        ]);
    }
}

