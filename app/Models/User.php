<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'avatar',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    // RELATIONSHIPS
    public function platformAccounts()
    {
        return $this->hasMany(PlatformAccount::class);
    }

    public function products()
    {
        return $this->hasMany(Product::class);
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    public function syncJobs()
    {
        return $this->hasMany(SyncJob::class);
    }

    public function commissions()
    {
        return $this->hasMany(Commission::class);
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }
}
