# BARYABest Mobile Navigation Flow (Guest-first)

This document describes the guest-first navigation that matches the requested flow:

`Device Home (mock)` -> `Splash` -> `Onboarding` -> `Home (Guest)`

The app does **not** force Login/Register at start. Auth screens open from inside the app (Home/Profile or locked actions).

---

## 1) Navigation Map (Stacks + Tabs)

### A) App Launch Stack (root navigator)

- `DeviceHomeMockScreen` (demo-only, optional)
  - Tap app icon -> `SplashScreen`
- `SplashScreen`
  - Guest -> `OnboardingScreen`
  - Auth user -> `/main` (`MainShell`)
  - Admin -> `/main` (`AdminShell`)
- `OnboardingScreen`
  - Skip / Start browsing -> `/main` (`MainShell`, guest)

### B) Main App (Bottom Tabs with per-tab stacks)

`MainShell` = bottom tabs + a **Navigator stack per tab**.

- Tab: `Home`
  - Root route: `AppRoutes.homeGuest` or `AppRoutes.homeAuth`
  - Screen: `HomeGuestScreen` / `HomeAuthScreen`
  - Push: `ProductListScreen`
  - Push: `ProductDetailScreen`
- Tab: `Compare`
  - Root route: `AppRoutes.compare`
  - Screen: `CompareScreen`
  - Push: `ProductDetailScreen` (optional)
- Tab: `Categories`
  - Root route: `AppRoutes.categories`
  - Screen: `CategoriesScreen`
  - Push: `AppRoutes.categoryProducts` -> `ProductListScreen`
  - Push: `ProductDetailScreen`
- Tab: `Saved`
  - Root route: `AppRoutes.savedGuest` or `AppRoutes.savedAuth`
  - Screen: `SavedScreen` (guest limited vs auth full)
  - Push: `ProductDetailScreen`
- Tab: `Profile`
  - Root route: `AppRoutes.profileGuest` or `AppRoutes.profileAuth`
  - Screen: `ProfileScreen` (guest CTA vs auth user data)
  - Push: `SettingsScreen`
  - Push (auth-only): `PlatformAccountsScreen`, `InventoryScreen`, `NotificationsScreen`

### C) Auth Stack (root navigator; opened from inside the app)

Auth is not shown at app start.

- `LoginScreen`
- `RegisterScreen`
- `ForgotPasswordScreen`

After successful login/register -> navigate to `/main` via `pushNamedAndRemoveUntil`. The `/main` route decides between `MainShell` and `AdminShell` based on the authenticated user.

---

## 2) Route Names

Central route constants live in `lib/navigation/app_routes.dart`.

**Root routes (MaterialApp)**
- Launch: `AppRoutes.deviceHomeMock`, `AppRoutes.splash`, `AppRoutes.onboarding`, `AppRoutes.main`
- Auth: `AppRoutes.login`, `AppRoutes.register`, `AppRoutes.forgotPassword`

**Tab root routes (inside `MainShell`)**
- Home: `AppRoutes.homeGuest`, `AppRoutes.homeAuth`
- Compare: `AppRoutes.compare`
- Categories: `AppRoutes.categories`, `AppRoutes.categoryProducts`
- Saved: `AppRoutes.savedGuest`, `AppRoutes.savedAuth`
- Profile: `AppRoutes.profileGuest`, `AppRoutes.profileAuth`

**Stack routes (inside tab navigators)**
- Products: `AppRoutes.productList`, `AppRoutes.productDetail`
- Settings: `AppRoutes.settings`
- Locked tools (require auth): `AppRoutes.inventory`, `AppRoutes.alerts`, `AppRoutes.platformAccounts`

---

## 3) Navigation Configuration (Pseudo / Dart)

Bottom tabs + per-tab stacks are implemented in `lib/features/shell/main_shell.dart`.

Conceptually:

```dart
Scaffold(
  body: IndexedStack(
    index: currentTab,
    children: [
      Navigator(onGenerateRoute: homeTabRoutes),
      Navigator(onGenerateRoute: compareTabRoutes),
      Navigator(onGenerateRoute: categoriesTabRoutes),
      Navigator(onGenerateRoute: savedTabRoutes),
      Navigator(onGenerateRoute: profileTabRoutes),
    ],
  ),
  bottomNavigationBar: NavigationBar(...),
);
```

Auth entry points:
- `SignInToUnlockCard` pushes `LoginScreen` / `RegisterScreen` on the **root navigator**
- `showLoginRequiredSheet()` shows a bottom sheet with `Login / Register / Maybe later`

---

## 4) Screen UI Notes (Dark Blue + Orange CTA)

Theme baseline:

- Background: deep navy (`#081029`), optional gradients for hero sections
- Primary CTA: orange (`#FF7A18`) via `colorScheme.primary`
- Guest badge: `GuestModeBadge` ("Guest Mode") visible when not authenticated

### SplashScreen

- Centered logo + loading indicator.
- Routes to onboarding for guests (no auth gate).

### OnboardingScreen

- Multi-step slides with progress bar + `Next`.
- Top-right `Skip`.
- Final CTA: `Start browsing` -> Home (Guest).

### HomeGuestScreen

- Shows `GuestModeBadge` and a clear CTA card: `SignInToUnlockCard` (Login/Register buttons).
- "Explore products" CTA navigates to `ProductListScreen`.
- Shows featured items (guest browsing works).

### HomeAuthScreen

- Shows store tools: `Connect stores`, `Inventory`, `Alerts`.
- "Explore products" remains available.

### ProductListScreen / ProductDetailScreen

- Search + list cards (platform tag + price).
- Save button:
  - Guest: allowed up to `SavedNotifier.guestLimit`
  - Beyond limit -> `showLoginRequiredSheet()`

### CompareScreen

- Search field + "Compare now".
- Shows best price highlight card and sorted results.

### SavedScreen

- Guest: shows a limit message + Login/Register CTA.
- Auth: unlimited saved items.

### ProfileScreen

- Guest: prominent Login/Register CTA + locked tools trigger login-required sheet.
- Auth: user card + tools + Settings + Logout.

### SettingsScreen

- Basic settings list (placeholder items) consistent with theme.

---

## 5) Guest vs Auth Rules (Implemented)

Guest can:

- Browse product list + product detail
- Compare results
- Browse categories
- Save up to `SavedNotifier.guestLimit`

Guest cannot (shows login-required sheet):

- Connect platform accounts (Shopee/Lazada/TikTok)
- Inventory tools / sync
- Alerts
- Unlimited saved items

---

## 6) Demo-only "Phone Home Screen" mock

Enable the mock launcher screen:

- Run with `--dart-define=SHOW_DEVICE_HOME_MOCK=true`
- Screen: `DeviceHomeMockScreen`

