<?php

namespace App\Http\Controllers;

use App\Http\Resources\AffiliateProductResource;
use App\Services\Affiliates\AffiliateClientFactory;
use App\Services\AuditLogger;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class SearchController extends Controller
{
    public function search(Request $request, AffiliateClientFactory $factory, AuditLogger $auditLogger)
    {
        $data = $request->validate([
            'platform' => 'required|in:shopee,lazada,tiktok',
            'query' => 'required|string|max:255',
            'page' => 'nullable|integer|min:1',
            'page_size' => 'nullable|integer|min:1|max:100',
        ]);

        $client = $factory->make($data['platform']);
        $page = $data['page'] ?? 1;
        $pageSize = $data['page_size'] ?? 20;

        $results = $client->search($data['query'], $page, $pageSize);

        try {
            $auditLogger->log(
                optional($request->user())->id,
                'search',
                [
                    'platform' => $data['platform'],
                    'query' => $data['query'],
                    'page' => $page,
                    'page_size' => $pageSize,
                    'result_count' => is_countable($results) ? count($results) : null,
                ]
            );
        } catch (\Throwable) {
            // Do not block product discovery if auditing fails.
        }

        if (!is_array($results)) {
            throw ValidationException::withMessages(['platform' => 'Search failed for platform ' . $data['platform']]);
        }

        // Normalize attribution
        $normalized = array_map(function ($item) use ($data) {
            $item['platform'] = $data['platform'];
            $item['data_source'] = sprintf('Data provided via %s Affiliate API', ucfirst($data['platform']));
            return $item;
        }, $results);

        return AffiliateProductResource::collection(collect($normalized));
    }
}
