<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SyncJob extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'platform_account_id',
        'job_type',
        'status',
        'details',
        'started_at',
        'finished_at',
    ];

    protected $casts = [
        'details' => 'array',
        'started_at' => 'datetime',
        'finished_at' => 'datetime',
    ];

    // RELATIONSHIPS
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function platformAccount()
    {
        return $this->belongsTo(PlatformAccount::class);
    }
}
