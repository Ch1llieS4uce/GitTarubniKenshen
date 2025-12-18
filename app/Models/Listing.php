<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Listing extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'platform_account_id',
        'platform_product_id',
        'price',
        'stock',
        'status',
        'synced_at',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'stock' => 'integer',
        'synced_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function platformAccount()
    {
        return $this->belongsTo(PlatformAccount::class);
    }

    public function priceHistory()
    {
        return $this->hasMany(PriceHistory::class);
    }
}
