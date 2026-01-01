<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use RuntimeException;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        $email = env('ADMIN_EMAIL', 'admin@baryabest.local');
        $password = env('ADMIN_PASSWORD', '');

        if (!is_string($password) || trim($password) === '') {
            if (app()->environment(['local', 'testing'])) {
                $password = 'password';
            } else {
                throw new RuntimeException('ADMIN_PASSWORD must be set to seed an admin user.');
            }
        }

        if ($password === 'password' && !app()->environment(['local', 'testing'])) {
            throw new RuntimeException('Refusing to seed an admin user with the default password in non-local environments.');
        }

        User::updateOrCreate(
            ['email' => $email],
            [
                'name' => 'Admin',
                'password' => Hash::make($password),
                'role' => 'admin',
            ]
        );
    }
}
