<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('platform_accounts')) {
            return;
        }

        $driver = DB::connection()->getDriverName();

        if (in_array($driver, ['mysql', 'mariadb'], true)) {
            DB::statement('ALTER TABLE platform_accounts MODIFY access_token TEXT NULL');
            DB::statement('ALTER TABLE platform_accounts MODIFY refresh_token TEXT NULL');
            return;
        }

        if ($driver === 'pgsql') {
            DB::statement('ALTER TABLE platform_accounts ALTER COLUMN access_token TYPE TEXT');
            DB::statement('ALTER TABLE platform_accounts ALTER COLUMN refresh_token TYPE TEXT');
            return;
        }

        if ($driver !== 'sqlite') {
            return;
        }

        // SQLite: rebuild table to change column types safely.
        DB::statement('PRAGMA foreign_keys=OFF');

        Schema::dropIfExists('platform_accounts_new');

        Schema::create('platform_accounts_new', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();

            $table->enum('platform', ['shopee', 'lazada', 'tiktok']);
            $table->string('account_name');
            $table->text('access_token')->nullable();
            $table->text('refresh_token')->nullable();
            $table->json('additional_data')->nullable();

            $table->timestamp('last_synced_at')->nullable();
            $table->timestamps();
        });

        DB::statement(
            'INSERT INTO platform_accounts_new (id, user_id, platform, account_name, access_token, refresh_token, additional_data, last_synced_at, created_at, updated_at)
             SELECT id, user_id, platform, account_name, access_token, refresh_token, additional_data, last_synced_at, created_at, updated_at
             FROM platform_accounts'
        );

        Schema::drop('platform_accounts');
        Schema::rename('platform_accounts_new', 'platform_accounts');

        Schema::table('platform_accounts', function (Blueprint $table) {
            $table->index(['user_id', 'platform']);
        });

        DB::statement('PRAGMA foreign_keys=ON');
    }

    public function down(): void
    {
        // No-op: shrinking token columns is potentially destructive.
    }
};
