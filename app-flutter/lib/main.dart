import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/device_home/device_home_mock_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/products/explore_products_screen.dart';
import 'features/shell/admin_shell.dart';
import 'features/shell/main_shell.dart';
import 'features/splash/splash_screen.dart';
import 'navigation/app_routes.dart';
import 'state/auth_notifier.dart';

void main() {
  // Debug: Log startup route configuration
  debugPrint('═══════════════════════════════════════════════════════');
  debugPrint('🚀 BaryaBest App Starting');
  debugPrint('   showDeviceHomeMock: ${AppConfig.showDeviceHomeMock}');
  debugPrint('   useMockData: ${AppConfig.useMockData}');
  debugPrint('   baseUrl: ${AppConfig.baseUrl}');
  debugPrint('   initialRoute: ${AppConfig.showDeviceHomeMock ? AppRoutes.deviceHomeMock : AppRoutes.splash}');
  debugPrint('═══════════════════════════════════════════════════════');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.deviceHomeMock:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DeviceHomeMockScreen(),
        );
      case AppRoutes.splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case AppRoutes.onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingScreen(),
        );
      case AppRoutes.main:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _MainEntry(),
        );
      case AppRoutes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case AppRoutes.register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ForgotPasswordScreen(),
        );
      case AppRoutes.exploreProducts:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ExploreProductsScreen(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => _UnknownRouteScreen(name: settings.name),
        );
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'BaryaBest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          // Brand colors extracted from app icon
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF6B4A), // Coral/Orange from icon
            onPrimary: Colors.white,
            secondary: Color(0xFF15657B), // Teal from icon background
            onSecondary: Colors.white,
            tertiary: Color(0xFFF15A29), // Warm orange accent
            surface: Color(0xFF0D3D4D), // Dark teal surface
            onSurface: Colors.white,
            surfaceContainerHighest: Color(0xFF15657B),
            error: Color(0xFFFF6B6B),
          ),
          scaffoldBackgroundColor: const Color(0xFF0A2835), // Deep teal background
          cardTheme: CardTheme(
            color: const Color(0xFF0D3D4D),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: const Color(0xFF15657B).withOpacity(0.2)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF0D3D4D),
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIconColor: const Color(0xFFFF6B4A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: const Color(0xFF15657B).withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: const Color(0xFF15657B).withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFF6B4A), width: 2.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B4A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              elevation: 4,
              shadowColor: const Color(0xFFFF6B4A).withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B4A),
              side: const BorderSide(color: Color(0xFFFF6B4A), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B4A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          listTileTheme: ListTileThemeData(
            tileColor: const Color(0xFF0D3D4D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            iconColor: const Color(0xFFFF6B4A),
            textColor: Colors.white,
            subtitleTextStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          chipTheme: const ChipThemeData(
            backgroundColor: Color(0xFF15657B),
            labelStyle: TextStyle(color: Colors.white),
            side: BorderSide.none,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: const Color(0xFF0A2835),
            indicatorColor: const Color(0xFFFF6B4A).withOpacity(0.2),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFFFF6B4A));
              }
              return IconThemeData(color: Colors.white.withOpacity(0.6));
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: Color(0xFFFF6B4A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                );
              }
              return TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              );
            }),
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        initialRoute: AppConfig.showDeviceHomeMock
            ? AppRoutes.deviceHomeMock
            : AppRoutes.splash,
        onGenerateRoute: _onGenerateRoute,
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

class _MainEntry extends ConsumerWidget {
  const _MainEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.user;
    if (auth.isAuthenticated && user != null && user.isAdmin) {
      return const AdminShell();
    }
    return const MainShell();
  }
}
