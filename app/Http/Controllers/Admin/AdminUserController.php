<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class AdminUserController extends Controller
{
    public function index(Request $request)
    {
        $perPage = (int)($request->query('per_page', 20));
        $perPage = max(1, min(100, $perPage));

        return User::query()
            ->select(['id', 'name', 'email', 'role', 'created_at'])
            ->latest()
            ->paginate($perPage);
    }

    public function updateRole(Request $request, int $id)
    {
        $data = $request->validate([
            'role' => 'required|in:seller,admin',
        ]);

        $user = User::findOrFail($id);
        $user->update(['role' => $data['role']]);

        return response()->json([
            'status' => 'success',
            'user' => $user->only(['id', 'name', 'email', 'role']),
        ]);
    }
}

