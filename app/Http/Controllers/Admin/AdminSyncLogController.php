<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SyncLog;
use Illuminate\Http\Request;

class AdminSyncLogController extends Controller
{
    public function index(Request $request)
    {
        $perPage = (int)($request->query('per_page', 20));
        $perPage = max(1, min(100, $perPage));

        $logs = SyncLog::query()
            ->with(['platformAccount.user'])
            ->latest()
            ->paginate($perPage);

        return response()->json($logs);
    }
}

