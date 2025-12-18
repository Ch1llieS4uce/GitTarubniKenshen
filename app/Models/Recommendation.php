<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Recommendation extends Model
{
    use HasFactory;

    protected $fillable = [
        'listing_id',
        'recommended_price',
        'confidence',
        'model_version',
        'generated_at',
    ];

    protected $casts = [
        'recommended_price' => 'decimal:2',
        'confidence' => 'decimal:2',
        'generated_at' => 'datetime',
    ];

    // RELATIONSHIPS
    public function listing()
    {
        return $this->belongsTo(Listing::class);
    }
}
