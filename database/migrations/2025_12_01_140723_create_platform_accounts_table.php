<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
public function up()
{
    Schema::create('platform_accounts', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained()->cascadeOnDelete();

        $table->enum('platform', ['shopee', 'lazada', 'tiktok']);
        $table->string('account_name');
        $table->string('access_token')->nullable();
        $table->string('refresh_token')->nullable();
        $table->json('additional_data')->nullable();

        $table->timestamp('last_synced_at')->nullable();
        $table->timestamps();

        $table->index(['user_id', 'platform']);
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('platform_accounts');
    }
};
