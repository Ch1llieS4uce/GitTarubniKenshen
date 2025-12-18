<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // If the correct table already exists, nothing to do.
        if (Schema::hasTable('price_histories')) {
            return;
        }

        // If the old table exists, rename it to match the model expectation.
        if (Schema::hasTable('price_history')) {
            Schema::rename('price_history', 'price_histories');
            return;
        }

        // Otherwise create fresh.
        Schema::create('price_histories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('listing_id')->constrained()->cascadeOnDelete();
            $table->decimal('price', 12, 2);
            $table->enum('source', ['platform', 'competitor'])->default('platform');
            $table->timestamp('recorded_at')->useCurrent()->nullable();
            $table->timestamps();
            $table->index(['listing_id', 'source']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('price_histories');
    }
};
