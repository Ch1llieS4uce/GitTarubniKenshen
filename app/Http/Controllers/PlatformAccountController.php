<?php

namespace App\Http\Controllers;

use App\Http\Requests\PlatformAccountRequest;
use App\Models\PlatformAccount;
use Illuminate\Http\Request;

class PlatformAccountController extends Controller
{
    public function index(Request $request)
    {
        return PlatformAccount::where('user_id', $request->user()->id)->get();
    }

    public function connect(PlatformAccountRequest $request)
    {
        $data = $request->validated();

        $account = PlatformAccount::create([
            'user_id'      => $request->user()->id,
            'platform'     => $data['platform'],
            'account_name' => $data['account_name'],
            'access_token' => $data['access_token'] ?? null,
            'refresh_token' => $data['refresh_token'] ?? null,
            'additional_data' => $data['additional_data'] ?? null,
        ]);

        return response()->json([
            'message' => 'Platform connected successfully',
            'data' => $account
        ], 201);
    }
}
