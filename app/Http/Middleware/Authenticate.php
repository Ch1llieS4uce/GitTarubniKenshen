<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Support\Facades\Route;

class Authenticate extends Middleware
{
    protected function redirectTo($request): ?string
    {
        if ($request->expectsJson()) {
            return null;
        }

        // This project is API-first and does not define a default web "login" route.
        // Avoid throwing RouteNotFoundException when a non-JSON request hits an auth-protected endpoint.
        return Route::has('login') ? route('login') : null;
    }
}
