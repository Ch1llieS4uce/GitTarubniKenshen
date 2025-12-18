<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'sku' => $this->sku,
            'description' => $this->description,
            'main_image' => $this->main_image,
            'cost_price' => (float)$this->cost_price,
            'desired_margin' => (float)$this->desired_margin,
            'attributes' => $this->attributes ?? [],
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
