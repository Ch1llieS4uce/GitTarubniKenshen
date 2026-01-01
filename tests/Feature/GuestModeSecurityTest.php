<?php

namespace Tests\Feature;

use App\Jobs\SyncPlatformProductsJob;
use App\Models\PlatformAccount;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Bus;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class GuestModeSecurityTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_can_browse_home_and_search(): void
    {
        $this->getJson('/api/home')
            ->assertOk()
            ->assertJsonStructure(['sections']);

        $this->getJson('/api/search?platform=shopee&query=earbuds')
            ->assertOk()
            ->assertJsonStructure(['data']);
    }

    public function test_guest_cannot_access_authenticated_endpoints(): void
    {
        $this->getJson('/api/platforms')->assertUnauthorized();
    }

    public function test_click_redirect_rejects_non_marketplace_hosts(): void
    {
        $this->getJson('/api/click/shopee?url=https://example.com/')
            ->assertStatus(422)
            ->assertJsonValidationErrors(['url']);
    }

    public function test_click_redirect_allows_marketplace_hosts(): void
    {
        $response = $this->get('/api/click/shopee?url=https://shopee.ph/product/earbuds-tws');

        $response->assertStatus(302);
        $response->assertHeader(
            'Location',
            'https://shopee.ph/product/earbuds-tws?aff_id=MOCK_SHOPEE'
        );
    }

    public function test_sync_is_scoped_to_platform_account_owner(): void
    {
        Bus::fake();

        $userA = User::factory()->create();
        $userB = User::factory()->create();

        $accountB = PlatformAccount::create([
            'user_id' => $userB->id,
            'platform' => 'shopee',
            'account_name' => 'B Account',
        ]);

        Sanctum::actingAs($userA);

        $this->postJson('/api/sync/' . $accountB->id)
            ->assertNotFound();

        Bus::assertNotDispatched(SyncPlatformProductsJob::class);
    }

    public function test_sync_dispatches_for_owner(): void
    {
        Bus::fake();

        $user = User::factory()->create();
        $account = PlatformAccount::create([
            'user_id' => $user->id,
            'platform' => 'shopee',
            'account_name' => 'My Account',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/sync/' . $account->id, ['job_type' => 'products'])
            ->assertStatus(202)
            ->assertJson([
                'message' => 'Sync job queued',
                'job_type' => 'products',
            ]);

        Bus::assertDispatched(SyncPlatformProductsJob::class, function (SyncPlatformProductsJob $job) use ($account) {
            return $job->platformAccountId === $account->id && $job->jobType === 'products';
        });
    }

    public function test_logout_revokes_only_current_token(): void
    {
        $user = User::factory()->create();

        $token1 = $user->createToken('device-1');
        $token2 = $user->createToken('device-2');

        $this->withHeader('Authorization', 'Bearer ' . $token1->plainTextToken)
            ->postJson('/api/auth/logout')
            ->assertOk()
            ->assertJson([
                'status' => 'success',
            ]);

        $this->assertDatabaseMissing('personal_access_tokens', [
            'id' => $token1->accessToken->id,
        ]);
        $this->assertDatabaseHas('personal_access_tokens', [
            'id' => $token2->accessToken->id,
        ]);
    }
}

