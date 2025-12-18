<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_login()
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Tester',
            'email' => 'tester@example.com',
            'password' => 'secret123',
        ]);

        $response->assertStatus(200)->assertJsonStructure(['status','user','token']);
    }
}
