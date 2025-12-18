<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SyncLog extends Model
{
    protected $fillable = [
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

    public function platformAccount()
    {
        return $this->belongsTo(PlatformAccount::class);
    }
}
