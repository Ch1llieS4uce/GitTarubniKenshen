<?php

namespace App\Http\Controllers;

use App\Services\Affiliates\AffiliateClientFactory;
use App\Services\AuditLogger;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class ClickController extends Controller
{
    public function redirect(Request $request, string $platform, AffiliateClientFactory $factory, AuditLogger $auditLogger)
    {
        $data = $request->validate([
            'url' => 'required|url|starts_with:http://,https://',
            'platform_product_id' => 'nullable|string|max:255',
        ]);

        $host = parse_url($data['url'], PHP_URL_HOST);
        if (!is_string($host) || $host === '') {
            throw ValidationException::withMessages(['url' => 'Invalid URL host']);
        }

        if (!$this->isAllowedHostForPlatform($platform, $host)) {
            throw ValidationException::withMessages([
                'url' => 'URL host is not allowed for platform ' . $platform,
            ]);
        }

        $client = $factory->make($platform);
        $affiliateUrl = $client->createAffiliateLink($data['url']);

        try {
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
        } catch (\Throwable) {
            // Do not block redirects if auditing fails.
        }

        return redirect()->away($affiliateUrl);
    }

    private function isAllowedHostForPlatform(string $platform, string $host): bool
    {
        $host = strtolower($host);

        return match ($platform) {
            'shopee' => $this->hostIs($host, 'shopee.ph'),
            'lazada' => $this->hostIs($host, 'lazada.com.ph'),
            'tiktok' => $this->hostIs($host, 'tiktok.com'),
            default => false,
        };
    }

    private function hostIs(string $host, string $suffix): bool
    {
        return $host === $suffix || str_ends_with($host, '.' . $suffix);
    }
}
