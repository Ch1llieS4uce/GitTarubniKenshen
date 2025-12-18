<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('commissions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->enum('platform', ['shopee', 'lazada', 'tiktok']);
            $table->string('platform_product_id')->nullable();
            $table->string('order_reference')->nullable();
            $table->decimal('commission_amount', 12, 2)->default(0);
            $table->string('currency', 10)->default('PHP');
            $table->enum('status', ['pending', 'approved', 'paid'])->default('pending');
            $table->timestamp('occurred_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'platform', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('commissions');
    }
};
