<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('favorites', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->enum('platform', ['shopee', 'lazada', 'tiktok']);
            $table->string('platform_product_id');
            $table->string('title')->nullable();
            $table->string('image')->nullable();
            $table->decimal('price', 12, 2)->nullable();
            $table->string('affiliate_url')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'platform', 'platform_product_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('favorites');
    }
};
