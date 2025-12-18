# BaryaBest Mobile App (Flutter) + API (Laravel)

## What’s included
- Flutter customer app in `app-flutter/` with onboarding, auth, dropshipper flows (home/search/products/inventory/alerts/profile), and admin flows (dashboard/users/sync logs).
- Laravel API endpoints under `routes/api.php` using Sanctum bearer tokens.
- A “working mock sync” path: platform sync uses the sample affiliate clients so you can test end-to-end without real Shopee/Lazada/TikTok credentials.
- AI pricing: `GET /api/listings/{id}/recommendation` stores a `recommendations` row using a heuristic engine, with an optional external AI override via `AI_PRICE_ENGINE_URL`.

## Local setup
### Backend
1. Configure `.env` for your DB and run:
   - `php artisan migrate`
2. Create an admin user (optional):
   - `php artisan db:seed --class=AdminUserSeeder`
   - Override defaults via `ADMIN_EMAIL` and `ADMIN_PASSWORD` in `.env`.
3. Run API + queue worker (sync runs via queue):
   - `php artisan serve --host 0.0.0.0 --port 8000`
   - `php artisan queue:work`

### Flutter
1. `cd app-flutter`
2. `flutter pub get`
3. Run (mock mode is on by default):
   - Real backend: `flutter run --dart-define=USE_MOCK_DATA=false --dart-define=API_BASE_URL=http://10.0.2.2:8000`
   - Mock data: `flutter run --dart-define=USE_MOCK_DATA=true`

## Key API routes used by the app
- Auth: `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/logout`, `GET /api/me`
- Catalog: `GET /api/home`, `GET /api/search`
- Products: `GET /api/products`, `POST /api/products`
- Inventory/Listings: `GET /api/listings`, `PUT /api/listings/{id}`
- Pricing/AI: `GET /api/listings/{id}/recommendation`
- Notifications: `GET /api/notifications`, `POST /api/notifications/{id}/read`
- Platforms: `GET /api/platforms`, `POST /api/platforms/connect`, `POST /api/sync/{platform_account_id}`
- Admin (role `admin`): `GET /api/admin/dashboard`, `GET /api/admin/users`, `PUT /api/admin/users/{id}/role`, `GET /api/admin/sync-logs`

## Next integration steps (production)
- Replace sample affiliate clients in `app/Services/PlatformSyncService.php` with real platform integrations and secure OAuth flows for `platform_accounts`.
- Add secure token persistence in Flutter (e.g. Keychain/Keystore) and refresh-token handling where applicable.
- Add push notifications (FCM/APNs) and server-side fanout (Laravel events/queues).
- Add platform webhooks (where available) to approach real-time sync instead of polling/scheduling only.

