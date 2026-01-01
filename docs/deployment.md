# Deployment checklist (Laravel API + Filament)

This is a production-focused checklist for deploying the BaryaBest backend.

## 1) Hosting prerequisites
- PHP (match `composer.json` requirements)
- A database supported by Laravel (MySQL/MariaDB/PostgreSQL recommended)
- Composer available on the server (or deploy `vendor/` from CI)
- Ability to run cron jobs and (ideally) a process manager for queues (Supervisor/systemd)

## 2) Filesystem / web root
- Point the web server document root to `public/` (not repo root).
- Ensure `storage/` and `bootstrap/cache/` are writable by the web user.

## 3) Environment configuration
- Create `.env` (do not commit it) and set at minimum:
  - `APP_ENV=production`
  - `APP_DEBUG=false`
  - `APP_KEY=...` (generate with `php artisan key:generate`)
  - `APP_URL=https://your-domain`
  - DB settings (`DB_CONNECTION`, `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`)
  - `LOG_LEVEL=info`
- Optional hardening:
  - `CORS_ALLOWED_ORIGINS=https://your-frontend-origin` (or `*` for API-only)
  - `SANCTUM_EXPIRATION=...` (minutes; optional)

## 4) Install + migrate
- `composer install --no-dev --optimize-autoloader`
- `php artisan migrate --force`

Optional admin panel:
- Seed an admin account (set `ADMIN_EMAIL` + `ADMIN_PASSWORD` first):
  - `php artisan db:seed --class=AdminUserSeeder`

## 5) Cache warmup
- `php artisan config:cache`
- `php artisan event:cache` (optional)
- Route caching is not enabled because this project includes route closures.

## 6) Queues (required for sync jobs)
Recommended:
- Set `QUEUE_CONNECTION=database`
- Run a worker via Supervisor/systemd:
  - `php artisan queue:work --tries=3 --timeout=60`

Shared hosting fallback:
- Use a cron to run `php artisan queue:work --stop-when-empty` frequently (less ideal).

## 7) Scheduler (recommended)
Run every minute:
- `* * * * * php /path/to/artisan schedule:run >> /dev/null 2>&1`

The scheduler currently:
- Dispatches hourly sync jobs for connected platform accounts.
- Prunes expired Sanctum tokens daily if `SANCTUM_EXPIRATION` is set.

## 8) Post-deploy sanity checks
- Health endpoint: `GET /up` should return 200.
- Guest browse: `GET /api/home` and `GET /api/search` should work without auth.
- Auth: register/login returns a bearer token; protected endpoints require it.
- Admin panel: `/admin` login works and is restricted to role `admin`.

