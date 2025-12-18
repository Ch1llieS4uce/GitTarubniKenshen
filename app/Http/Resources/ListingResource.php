<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ListingResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'product' => new ProductResource($this->whenLoaded('product')),
            'platform_account' => [
                'id' => $this->platformAccount->id ?? null,
                'account_name' => $this->platformAccount->account_name ?? null,
                'platform' => $this->platformAccount->platform ?? null,
            ],
            'platform_product_id' => $this->platform_product_id,
            'price' => (float)$this->price,
            'stock' => (int)$this->stock,
            'status' => $this->status,
            'synced_at' => $this->synced_at,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
