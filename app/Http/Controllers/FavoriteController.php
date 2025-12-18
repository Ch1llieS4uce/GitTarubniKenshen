<?php

namespace App\Http\Controllers;

use App\Models\Favorite;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function index(Request $request)
    {
        return $request->user()->favorites()->latest()->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'platform' => 'required|in:shopee,lazada,tiktok',
            'platform_product_id' => 'required|string|max:255',
            'title' => 'nullable|string|max:255',
            'image' => 'nullable|string|max:1024',
            'price' => 'nullable|numeric|min:0',
            'affiliate_url' => 'nullable|string|max:1024',
        ]);

        $favorite = Favorite::updateOrCreate(
            [
                'user_id' => $request->user()->id,
                'platform' => $data['platform'],
                'platform_product_id' => $data['platform_product_id'],
            ],
            [
                'title' => $data['title'] ?? null,
                'image' => $data['image'] ?? null,
                'price' => $data['price'] ?? null,
                'affiliate_url' => $data['affiliate_url'] ?? null,
            ]
        );

        return response()->json($favorite, 201);
    }

    public function destroy(Request $request, $id)
    {
        $favorite = Favorite::where('user_id', $request->user()->id)->findOrFail($id);
        $favorite->delete();

        return response()->json(['message' => 'Removed from favorites']);
    }
}
