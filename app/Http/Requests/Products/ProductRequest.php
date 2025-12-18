<?php

namespace App\Http\Requests\Products;

use Illuminate\Foundation\Http\FormRequest;

class ProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title'          => 'required|string|max:255',
            'sku'            => 'nullable|string|max:255',
            'description'    => 'nullable|string',
            'main_image'     => 'nullable|string',
            'cost_price'     => 'required|numeric|min:0',
            'desired_margin' => 'required|numeric|min:0',
            'attributes'     => 'nullable|array',
        ];
    }
}
