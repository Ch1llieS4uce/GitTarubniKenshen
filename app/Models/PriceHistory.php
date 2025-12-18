<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PriceHistory extends Model
{
    use HasFactory;

    protected $fillable = [
        'listing_id',
        'price',
        'source',
        'recorded_at',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'recorded_at' => 'datetime',
    ];

    // RELATIONSHIPS
    public function listing()
    {
        return $this->belongsTo(Listing::class);
    }
}
