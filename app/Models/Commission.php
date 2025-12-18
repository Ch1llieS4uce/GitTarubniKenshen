<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Commission extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'platform',
        'platform_product_id',
        'order_reference',
        'commission_amount',
        'currency',
        'status',
        'occurred_at',
    ];

    protected $casts = [
        'commission_amount' => 'decimal:2',
        'occurred_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
