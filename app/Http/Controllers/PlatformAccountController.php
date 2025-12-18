<?php

namespace App\Http\Controllers;

use App\Models\PlatformAccount;
use Illuminate\Http\Request;

class PlatformAccountController extends Controller
{
    public function index(Request $request)
    {
        return PlatformAccount::where('user_id', $request->user()->id)->get();
    }

    public function connect(Request $request)
    {
        $request->validate([
            'platform'     => 'required|in:shopee,lazada,tiktok',
            'account_name' => 'required',
        ]);

        $account = PlatformAccount::create([
            'user_id'      => $request->user()->id,
            'platform'     => $request->platform,
            'account_name' => $request->account_name,
            'access_token' => $request->access_token,
            'refresh_token'=> $request->refresh_token,
            'additional_data' => $request->additional_data,
        ]);

        return response()->json([
            'message' => 'Platform connected successfully',
            'data' => $account
        ], 201);
    }
}
