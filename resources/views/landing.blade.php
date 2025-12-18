<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $appName }} API</title>
    <style>
        body { font-family: Arial, sans-serif; background:#f7f7f7; margin:0; padding:0; color:#111; }
        .wrap { max-width: 840px; margin: 40px auto; background: #fff; border: 1px solid #e5e5e5; border-radius: 12px; padding: 32px; }
        h1 { margin-top: 0; }
        code { background:#f1f1f1; padding:2px 6px; border-radius:4px; }
        .card { margin-top:16px; padding:16px; border:1px solid #e5e5e5; border-radius:8px; background:#fafafa; }
        a { color:#0d6efd; text-decoration:none; }
        a:hover { text-decoration:underline; }
        ul { padding-left: 18px; }
    </style>
</head>
<body>
    <div class="wrap">
        <h1>{{ $appName }}</h1>
        <p>Backend is running. Quick links and sample calls:</p>

        <div class="card">
            <h3>API</h3>
            <ul>
                <li>Search: <code>{{ $apiBase }}/api/search?platform=shopee&query=sample</code></li>
                <li>Click redirect: <code>{{ $apiBase }}/api/click/shopee?url=https://shopee.ph/sample-earbuds</code></li>
            </ul>
            <p>See <code>docs/frontend_scaffold.md</code> for full contract.</p>
        </div>

        <div class="card">
            <h3>Admin</h3>
            <p><a href="{{ $apiBase }}/admin">{{ $apiBase }}/admin</a> (login with an admin user).</p>
        </div>

        <div class="card">
            <h3>Next steps</h3>
            <ul>
                <li>Point Flutter <code>baseUrl</code> to <code>{{ $apiBase }}</code>.</li>
                <li>Use <code>/api/search</code> for listing products and <code>/api/click/{platform}</code> for tracked redirects.</li>
            </ul>
        </div>
    </div>
</body>
</html>
