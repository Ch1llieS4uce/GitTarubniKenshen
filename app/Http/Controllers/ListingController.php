<?php

namespace App\Http\Controllers;

use App\Models\Listing;
use App\Http\Requests\Listings\UpdateListingRequest;
use App\Http\Resources\ListingResource;
use Illuminate\Http\Request;

class ListingController extends Controller
{
    public function index(Request $request)
    {
        $perPage = (int)($request->query('per_page', 20));
        $perPage = max(1, min(100, $perPage));

        $query = Listing::query()
            ->with(['product', 'platformAccount'])
            ->whereHas('product', fn ($q) => $q->where('user_id', $request->user()->id))
            ->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        }

        if ($request->filled('platform')) {
            $platform = $request->query('platform');
            $query->whereHas('platformAccount', fn ($q) => $q->where('platform', $platform));
        }

        return ListingResource::collection($query->paginate($perPage));
    }

    public function show(Request $request, $id)
    {
        $listingQuery = Listing::with(['product', 'platformAccount']);

        if (($request->user()?->role ?? 'seller') !== 'admin') {
            $listingQuery->whereHas('product', fn ($q) => $q->where('user_id', $request->user()->id));
        }

        $listing = $listingQuery->findOrFail($id);
        return new ListingResource($listing);
    }

    public function priceHistory(Request $request, $id)
    {
        $listingQuery = Listing::query();

        if (($request->user()?->role ?? 'seller') !== 'admin') {
            $listingQuery->whereHas('product', fn ($q) => $q->where('user_id', $request->user()->id));
        }

        $listing = $listingQuery->findOrFail($id);

        return $listing->priceHistory()->latest()->get();
    }

    public function update(UpdateListingRequest $request, $id)
    {
        $listing = Listing::query()
            ->whereHas('product', fn ($q) => $q->where('user_id', $request->user()->id))
            ->findOrFail($id);

        $listing->update($request->validated());

        return new ListingResource($listing->load(['product', 'platformAccount']));
    }
}
