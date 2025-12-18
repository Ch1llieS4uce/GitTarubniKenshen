<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('landing', [
        'appName' => config('app.name', 'BBest'),
        'apiBase' => config('app.url'),
    ]);
});
