<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'title',
        'sku',
        'description',
        'main_image',
        'cost_price',
        'desired_margin',
        'attributes',
    ];

    protected $casts = [
        'cost_price' => 'decimal:2',
        'desired_margin' => 'decimal:2',
        'attributes' => 'array',
    ];

    // RELATIONSHIPS
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function listings()
    {
        return $this->hasMany(Listing::class);
    }
}
