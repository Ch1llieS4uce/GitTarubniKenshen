<?php

namespace App\Http\Controllers;

use App\Jobs\SyncPlatformProductsJob;
use App\Models\PlatformAccount;
use Illuminate\Http\Request;

class SyncController extends Controller
{
    public function sync(Request $request, int $platform_account_id)
    {
        $data = $request->validate([
            'job_type' => 'nullable|in:products,prices,inventory',
        ]);

        $jobType = $data['job_type'] ?? 'products';

        $query = PlatformAccount::query();

        if (($request->user()?->role ?? 'seller') !== 'admin') {
            $query->where('user_id', $request->user()->id);
        }

        $account = $query->findOrFail($platform_account_id);

        SyncPlatformProductsJob::dispatch($account->id, $jobType);

        return response()->json([
            'message' => 'Sync job queued',
            'job_type' => $jobType,
        ], 202);
    }
}

