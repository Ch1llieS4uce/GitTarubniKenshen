import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/device_home/device_home_mock_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/admin_shell.dart';
import 'features/shell/main_shell.dart';
import 'features/splash/splash_screen.dart';
import 'navigation/app_routes.dart';
import 'state/auth_notifier.dart';

void main() {
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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1C1B4B),
            primary: const Color(0xFFFF7A18),
            secondary: const Color(0xFF3A86FF),
          ),
          scaffoldBackgroundColor: const Color(0xFF081029),
          textTheme: Theme.of(context)
              .textTheme
              .apply(bodyColor: Colors.white, displayColor: Colors.white),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
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
