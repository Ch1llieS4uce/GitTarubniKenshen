import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../navigation/app_routes.dart';
import '../../state/auth_notifier.dart';
import '../categories/categories_screen.dart';
import '../compare/compare_screen.dart';
import '../home/home_auth_screen.dart';
import '../home/home_guest_screen.dart';
import '../inventory/inventory_screen.dart';
import '../notifications/notifications_screen.dart';
import '../products/product_detail_screen.dart';
import '../products/product_list_screen.dart';
import '../profile/platform_accounts_screen.dart';
import '../profile/profile_screen.dart';
import '../saved/saved_screen.dart';
import '../settings/settings_screen.dart';

enum MainTab {
  home,
  compare,
  categories,
  saved,
  profile,
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({
    super.key,
    this.initialTab = MainTab.home,
  });

  final MainTab initialTab;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late int _index = widget.initialTab.index;

  final _navigatorKeys = <MainTab, GlobalKey<NavigatorState>>{
    MainTab.home: GlobalKey<NavigatorState>(),
    MainTab.compare: GlobalKey<NavigatorState>(),
    MainTab.categories: GlobalKey<NavigatorState>(),
    MainTab.saved: GlobalKey<NavigatorState>(),
    MainTab.profile: GlobalKey<NavigatorState>(),
  };

  void _handleBackNavigation() {
    final tab = MainTab.values[_index];
    final navigator = _navigatorKeys[tab]?.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return;
    }
    if (tab != MainTab.home) {
      setState(() => _index = MainTab.home.index);
      return;
    }

    Navigator.of(context, rootNavigator: true).maybePop();
  }

  void _onTabSelected(int index) {
    final nextTab = MainTab.values[index];
    final currentTab = MainTab.values[_index];
    if (nextTab == currentTab) {
      _navigatorKeys[nextTab]
          ?.currentState
          ?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _index = index);
  }

  Route<dynamic> _onGenerateRoute(MainTab tab, RouteSettings settings) {
    final isAuthenticated = ref.read(authNotifierProvider).isAuthenticated;
    switch (settings.name) {
      case Navigator.defaultRouteName:
        return MaterialPageRoute(
          settings: RouteSettings(
            name: _rootRouteNameForTab(tab, isAuthenticated),
          ),
          builder: (_) => _rootForTab(tab, isAuthenticated),
        );
      case AppRoutes.homeGuest:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeGuestScreen(),
        );
      case AppRoutes.homeAuth:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeAuthScreen(),
        );
      case AppRoutes.compare:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CompareScreen(),
        );
      case AppRoutes.categories:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CategoriesScreen(),
        );
      case AppRoutes.categoryProducts:
        final args = settings.arguments;
        final title = args is Map ? args['title'] as String? : null;
        final query = args is Map ? args['query'] as String? : null;
        final category = (title ?? query ?? '').trim();
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductListScreen(
            title: category.isEmpty ? 'Category' : category,
            initialQuery: category.isEmpty ? '' : category,
          ),
        );
      case AppRoutes.savedGuest:
      case AppRoutes.savedAuth:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SavedScreen(),
        );
      case AppRoutes.profileGuest:
      case AppRoutes.profileAuth:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileScreen(),
        );
      case AppRoutes.platformAccounts:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PlatformAccountsScreen(),
        );
      case AppRoutes.inventory:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const InventoryScreen(),
        );
      case AppRoutes.alerts:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotificationsScreen(),
        );
      case AppRoutes.productList:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductListScreen(
            title: (settings.arguments as Map?)?['title'] as String?,
            initialQuery: (settings.arguments as Map?)?['query'] as String?,
          ),
        );
      case AppRoutes.productDetail:
        final args = settings.arguments;
        if (args is! ProductDetailArgs) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => _InvalidRouteArgsScreen(name: settings.name),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductDetailScreen(
            product: args.product,
          ),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SettingsScreen(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => _UnknownRouteScreen(name: settings.name),
        );
    }
  }

  String _rootRouteNameForTab(MainTab tab, bool isAuthenticated) {
    switch (tab) {
      case MainTab.home:
        return isAuthenticated ? AppRoutes.homeAuth : AppRoutes.homeGuest;
      case MainTab.compare:
        return AppRoutes.compare;
      case MainTab.categories:
        return AppRoutes.categories;
      case MainTab.saved:
        return isAuthenticated ? AppRoutes.savedAuth : AppRoutes.savedGuest;
      case MainTab.profile:
        return isAuthenticated ? AppRoutes.profileAuth : AppRoutes.profileGuest;
    }
  }

  Widget _rootForTab(MainTab tab, bool isAuthenticated) {
    switch (tab) {
      case MainTab.home:
        return isAuthenticated ? const HomeAuthScreen() : const HomeGuestScreen();
      case MainTab.compare:
        return const CompareScreen();
      case MainTab.categories:
        return const CategoriesScreen();
      case MainTab.saved:
        return const SavedScreen();
      case MainTab.profile:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            return;
          }
          _handleBackNavigation();
        },
        child: Scaffold(
          body: IndexedStack(
            index: _index,
            children: MainTab.values
                .map(
                  (tab) => Navigator(
                    key: _navigatorKeys[tab],
                    onGenerateRoute: (settings) =>
                        _onGenerateRoute(tab, settings),
                  ),
                )
                .toList(),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _onTabSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.compare_arrows_outlined),
                selectedIcon: Icon(Icons.compare_arrows),
                label: 'Compare',
              ),
              NavigationDestination(
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category),
                label: 'Categories',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border),
                selectedIcon: Icon(Icons.bookmark),
                label: 'Saved',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      );
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: Center(
          child: Text('Unknown route: ${name ?? '(null)'}'),
        ),
      );
}

class _InvalidRouteArgsScreen extends StatelessWidget {
  const _InvalidRouteArgsScreen({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Invalid route arguments')),
        body: Center(
          child: Text('Missing/invalid arguments for route: ${name ?? '(null)'}'),
        ),
      );
}
