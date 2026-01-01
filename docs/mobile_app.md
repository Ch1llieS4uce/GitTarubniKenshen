# BaryaBest Mobile App (Flutter) + API (Laravel)

## What’s included
- Flutter mobile app in `app-flutter/` with guest-first onboarding and optional auth.
- Laravel API in `routes/api.php` using Sanctum bearer tokens for authenticated endpoints.
- Public discovery endpoints (`/api/home`, `/api/search`) support Guest Mode browsing.
- Mock marketplace clients (Shopee/Lazada/TikTok) so demos work without real affiliate credentials.
- AI pricing endpoint (`GET /api/listings/{id}/recommendation`) with optional external override via `AI_PRICE_ENGINE_URL`.

## Local setup

### Backend (Laravel)
If you’re using XAMPP on Windows, run artisan with:
- `C:\Xampp\php\php.exe`

1. Copy `.env.example` to `.env` and configure DB settings.
2. Generate an app key:
   - `C:\Xampp\php\php.exe artisan key:generate`
3. Run migrations:
   - `C:\Xampp\php\php.exe artisan migrate`
4. Start the API:
   - `C:\Xampp\php\php.exe artisan serve --host 0.0.0.0 --port 8000`
5. Run the queue worker (sync runs via queue):
   - `C:\Xampp\php\php.exe artisan queue:work`

Optional:
- Create an admin user for the Filament panel:
  - Set `ADMIN_EMAIL` and `ADMIN_PASSWORD` in `.env`
  - Run `C:\Xampp\php\php.exe artisan db:seed --class=AdminUserSeeder`
- External AI engine override:
  - Set `AI_PRICE_ENGINE_URL` (see `tools/ai_price_engine/`)

### Flutter
1. `cd app-flutter`
2. `flutter pub get`
3. Run:
   - Real backend: `flutter run --dart-define=USE_MOCK_DATA=false --dart-define=API_BASE_URL=http://10.0.2.2:8000`
   - Mock mode (no backend): `flutter run --dart-define=USE_MOCK_DATA=true`

## Key API routes used by the app
Public (Guest Mode):
- `GET /api/home`
- `GET /api/search`
- `GET /api/click/{platform}`

Authenticated (Sanctum):
- Auth: `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/logout`, `GET /api/me`
- Platforms/sync: `GET /api/platforms`, `POST /api/platforms/connect`, `POST /api/sync/{platform_account_id}`
- Products/listings: `GET /api/products`, `GET /api/listings`, `PUT /api/listings/{id}`
- Pricing/AI: `GET /api/listings/{id}/recommendation`
- Notifications: `GET /api/notifications`, `POST /api/notifications/{id}/read`
- Favorites: `GET /api/favorites`, `POST /api/favorites`, `DELETE /api/favorites/{id}`

Admin (role = `admin`):
- `GET /api/admin/dashboard`, `GET /api/admin/users`, `PUT /api/admin/users/{id}/role`, `GET /api/admin/sync-logs`

## Production notes (high level)
- Set `APP_ENV=production`, `APP_DEBUG=false`, `LOG_LEVEL=info`
- Run `php artisan config:cache`
- Run a queue worker and scheduler (`php artisan schedule:run`)

