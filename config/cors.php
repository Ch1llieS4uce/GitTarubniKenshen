<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    // This API uses bearer tokens; credentials/cookies are not required.
    // Keeping this false allows `allowed_origins` to remain `['*']` for local dev.
    'supports_credentials' => false,
];
