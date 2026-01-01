<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\PlatformAccountController;
use App\Http\Controllers\ListingController;
use App\Http\Controllers\RecommendationController;
use App\Http\Controllers\SearchController;
use App\Http\Controllers\ClickController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\SyncController;
use App\Http\Controllers\AffiliateProductController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminSyncLogController;
use App\Http\Controllers\Admin\AdminUserController;
use Illuminate\Http\Request;

Route::middleware('throttle:auth-register')->post('/auth/register', [AuthController::class, 'register']);
Route::middleware('throttle:auth-login')->post('/auth/login', [AuthController::class, 'login']);

// Affiliate search and click tracking (public; add throttling as needed)
Route::middleware('throttle:public')->get('/search', [SearchController::class, 'search']);
Route::middleware('throttle:public')->get('/click/{platform}', [ClickController::class, 'redirect'])
    ->whereIn('platform', ['shopee', 'lazada', 'tiktok']);

Route::middleware('throttle:public')->get('/home', [HomeController::class, 'home']);

// New: Affiliate products API with pagination and filtering
Route::middleware('throttle:public')->group(function () {
    Route::get('/affiliate-products', [AffiliateProductController::class, 'index']);
    Route::get('/affiliate-products/stats', [AffiliateProductController::class, 'stats']);
    Route::get('/affiliate-products/{platform}/{id}', [AffiliateProductController::class, 'show'])
        ->whereIn('platform', ['shopee', 'lazada', 'tiktok']);
});


Route::middleware(['auth:sanctum', 'throttle:auth'])->group(function () {
    Route::get('/me', function (Request $request) {
        return $request->user();
    });

    Route::post('/sync/{platform_account_id}', [SyncController::class, 'sync']);


    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // Products
    Route::get('/products', [ProductController::class, 'index']);
    Route::post('/products', [ProductController::class, 'store']);
    Route::get('/products/{id}', [ProductController::class, 'show']);
    Route::put('/products/{id}', [ProductController::class, 'update']);
    Route::delete('/products/{id}', [ProductController::class, 'destroy']);

    // Platform Accounts
    Route::get('/platforms', [PlatformAccountController::class, 'index']);
    Route::post('/platforms/connect', [PlatformAccountController::class, 'connect']);

    // Listings
    Route::get('/listings', [ListingController::class, 'index']);
    Route::get('/listings/{id}', [ListingController::class, 'show']);
    Route::put('/listings/{id}', [ListingController::class, 'update']);
    Route::get('/listings/{id}/prices', [ListingController::class, 'priceHistory']);

    // AI Recommendation
    Route::get('/listings/{id}/recommendation', [RecommendationController::class, 'getRecommendation']);

    Route::get('/notifications', [\App\Http\Controllers\NotificationController::class, 'index']);
    Route::post('/notifications/{id}/read', [\App\Http\Controllers\NotificationController::class, 'markRead']);

    // Favorites
    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::post('/favorites', [FavoriteController::class, 'store']);
    Route::delete('/favorites/{id}', [FavoriteController::class, 'destroy']);

});

Route::middleware(['auth:sanctum', 'admin.only'])->prefix('admin')->group(function () {
    Route::get('/dashboard', [AdminDashboardController::class, 'index']);
    Route::get('/users', [AdminUserController::class, 'index']);
    Route::put('/users/{id}/role', [AdminUserController::class, 'updateRole']);
    Route::get('/sync-logs', [AdminSyncLogController::class, 'index']);
});
