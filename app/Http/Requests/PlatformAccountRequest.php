<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class PlatformAccountRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'platform' => 'required|in:shopee,lazada,tiktok',
            'account_name' => 'required|string|max:255',
            'access_token' => 'nullable|string|max:4096',
            'refresh_token' => 'nullable|string|max:4096',
            'additional_data' => 'nullable|array',
        ];
    }
}
