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
    Schema::create('listings', function (Blueprint $table) {
        $table->id();
        $table->foreignId('product_id')->constrained()->cascadeOnDelete();
        $table->foreignId('platform_account_id')->constrained()->cascadeOnDelete();

        $table->string('platform_product_id')->index();
        $table->decimal('price', 12, 2)->default(0);
        $table->integer('stock')->default(0);
        $table->enum('status', ['active', 'inactive'])->default('active');

        $table->timestamp('synced_at')->nullable();
        $table->timestamps();

        $table->unique(['platform_account_id', 'platform_product_id']);
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('listings');
    }
};
