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
    Schema::create('recommendations', function (Blueprint $table) {
        $table->id();
        $table->foreignId('listing_id')->constrained()->cascadeOnDelete();

        $table->decimal('recommended_price', 12, 2);
        $table->decimal('confidence', 5, 2)->default(0); // %
        $table->string('model_version')->nullable();

        $table->timestamp('generated_at')->useCurrent();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('recommendations');
    }
};
