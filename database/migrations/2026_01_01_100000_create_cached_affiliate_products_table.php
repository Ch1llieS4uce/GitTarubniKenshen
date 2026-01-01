<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('cached_affiliate_products', function (Blueprint $table) {
            $table->id();
            $table->string('platform', 20)->index(); // lazada, shopee, tiktok
            $table->string('platform_product_id', 64)->index();
            $table->string('title', 512);
            $table->decimal('price', 12, 2)->nullable();
            $table->decimal('original_price', 12, 2)->nullable();
            $table->decimal('discount', 5, 4)->nullable(); // 0.0000 to 1.0000
            $table->decimal('rating', 3, 2)->nullable(); // 0.00 to 5.00
            $table->unsignedInteger('review_count')->nullable();
            $table->decimal('seller_rating', 3, 2)->nullable();
            $table->unsignedBigInteger('sales')->nullable();
            $table->text('image')->nullable();
            $table->text('url');
            $table->text('affiliate_url')->nullable();
            $table->string('category', 128)->nullable()->index();
            $table->json('extra_data')->nullable(); // For any additional fields
            $table->timestamp('synced_at')->nullable()->index();
            $table->timestamps();

            // Unique constraint: one product per platform
            $table->unique(['platform', 'platform_product_id'], 'platform_product_unique');

            // Full-text search index (MySQL)
            $table->fullText(['title'], 'title_fulltext');
        });

        // Add indexes for common queries
        Schema::table('cached_affiliate_products', function (Blueprint $table) {
            $table->index(['platform', 'synced_at']);
            $table->index(['platform', 'price']);
            $table->index(['platform', 'rating']);
            $table->index(['platform', 'sales']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('cached_affiliate_products');
    }
};
