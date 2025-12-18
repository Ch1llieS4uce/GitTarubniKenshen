<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class PriceHistoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'listing_id' => 'required|exists:listings,id',
            'price' => 'required|numeric|min:0',
            'source' => 'nullable|string|max:255',
            'recorded_at' => 'nullable|date',
        ];
    }
}
