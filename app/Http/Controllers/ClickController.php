<?php

namespace App\Http\Controllers;

use App\Services\Affiliates\AffiliateClientFactory;
use App\Services\AuditLogger;
use Illuminate\Http\Request;

class ClickController extends Controller
{
    public function redirect(Request $request, string $platform, AffiliateClientFactory $factory, AuditLogger $auditLogger)
    {
        $data = $request->validate([
            'url' => 'required|url',
            'platform_product_id' => 'nullable|string|max:255',
        ]);

        $client = $factory->make($platform);
        $affiliateUrl = $client->createAffiliateLink($data['url']);

        $auditLogger->log(
            optional($request->user())->id,
            'click_redirect',
            [
                'platform' => $platform,
                'platform_product_id' => $data['platform_product_id'] ?? null,
                'target_url' => $data['url'],
                'affiliate_url' => $affiliateUrl,
            ],
            subjectType: 'affiliate_click',
            subjectId: $data['platform_product_id'] ?? null
        );

        return redirect()->away($affiliateUrl);
    }
}
