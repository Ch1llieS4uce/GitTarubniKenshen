class AppRoutes {
  static const deviceHomeMock = '/device_home_mock';

  static const splash = '/splash';
  static const onboarding = '/onboarding';

  // Main entry (bottom tabs container)
  static const main = '/main';

  // ✅ Guest/Auth home split (for the Home tab content)
  static const homeGuest = '/home/guest';
  static const homeAuth = '/home/auth';

  // Auth (opened from Home/Profile, not first screen)
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot_password';

  // Products (stack screens)
  static const productList = '/products';
  static const productDetail = '/products/detail';

  // ✅ Tabs + stacks needed by your navigation design
  static const compare = '/compare';
  static const categories = '/categories';
  static const categoryProducts = '/categories/products';

  static const savedGuest = '/saved/guest';
  static const savedAuth = '/saved/auth';

  static const profileGuest = '/profile/guest';
  static const profileAuth = '/profile/auth';

  static const settings = '/settings';

  static const inventory = '/inventory';
  static const alerts = '/alerts';
  static const platformAccounts = '/platform_accounts';
}
