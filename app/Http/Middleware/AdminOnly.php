<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminOnly
{
    public function handle($request, Closure $next)
    {
        $user = $request instanceof Request ? $request->user() : null;
        if (!$user || $user->role !== 'admin') {
            abort(403, 'Unauthorized');
        }

        return $next($request);
    }
}
