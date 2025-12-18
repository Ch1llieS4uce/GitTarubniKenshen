<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSyncLogsTable extends Migration
{
    public function up()
    {
        Schema::create('sync_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('platform_account_id')->nullable()->index();
            $table->enum('job_type', ['products', 'prices', 'inventory'])->default('products');
            $table->enum('status', ['pending', 'running', 'success', 'failed'])->default('pending');
            $table->json('details')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('finished_at')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('sync_logs');
    }
}
