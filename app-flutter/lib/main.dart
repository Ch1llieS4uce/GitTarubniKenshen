import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/admin_shell.dart';
import 'features/shell/app_shell.dart';
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

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, _) {
          final auth = ref.watch(authNotifierProvider);
          final home = auth.isAuthenticated
              ? (auth.user!.isAdmin ? const AdminShell() : const AppShell())
              : const OnboardingScreen();

          return MaterialApp(
            title: 'BaryaBest',
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
            home: home,
          );
        },
      );
}
