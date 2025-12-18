<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class NotificationResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'message' => $this->message,
            'type' => $this->type,
            'is_read' => (bool)$this->is_read,
            'read_at' => $this->read_at,
            'created_at' => $this->created_at,
        ];
    }
}
