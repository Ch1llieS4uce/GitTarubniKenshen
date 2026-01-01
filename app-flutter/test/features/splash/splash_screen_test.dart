import 'package:baryabest_app/features/splash/splash_screen.dart';
import 'package:baryabest_app/navigation/app_routes.dart';
import 'package:baryabest_app/providers.dart';
import 'package:baryabest_app/services/home_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHomeService extends HomeService {
  _FakeHomeService() : super(Dio());

  @override
  Future<List<HomeSection>> fetchHome() async => const [
        HomeSection(title: 'Flash Deals', items: []),
      ];
}

void main() {
  group('SplashScreen', () {
    final routes = <String, WidgetBuilder>{
      AppRoutes.onboarding: (_) => const _PlaceholderRoute(),
      AppRoutes.main: (_) => const _PlaceholderRoute(),
    };

    testWidgets('displays splash screen with gradient background', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeServiceProvider.overrideWithValue(_FakeHomeService()),
          ],
          child: MaterialApp(
            routes: routes,
            home: const SplashScreen(),
          ),
        ),
      );

      // Verify scaffold is displayed
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify gradient container is present
      expect(find.byType(Container), findsWidgets);

      await tester.pump();
    });

    testWidgets('displays logo image', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeServiceProvider.overrideWithValue(_FakeHomeService()),
          ],
          child: MaterialApp(
            routes: routes,
            home: const SplashScreen(),
          ),
        ),
      );

      // Verify Image widget is present
      expect(find.byType(Image), findsOneWidget);

      await tester.pump();
    });

    testWidgets('displays app title text', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeServiceProvider.overrideWithValue(_FakeHomeService()),
          ],
          child: MaterialApp(
            routes: routes,
            home: const SplashScreen(),
          ),
        ),
      );

      // Verify "BARYABest" title text
      expect(find.text('BARYABest'), findsOneWidget);

      await tester.pump();
    });

    testWidgets('has correct screen structure', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeServiceProvider.overrideWithValue(_FakeHomeService()),
          ],
          child: MaterialApp(
            routes: routes,
            home: const SplashScreen(),
          ),
        ),
      );

      // Verify column layout is used
      expect(find.byType(Column), findsWidgets);

      await tester.pump();
    });

    testWidgets('navigates to home screen after timer', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeServiceProvider.overrideWithValue(_FakeHomeService()),
          ],
          child: MaterialApp(
            routes: routes,
            home: const SplashScreen(),
          ),
        ),
      );

      // Initially on splash screen
      expect(find.byType(SplashScreen), findsOneWidget);

      // Wait for navigation timer (2 seconds) plus settle
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // After timer, should navigate away from splash
      expect(find.byType(SplashScreen), findsNothing);
    });
  });
}

class _PlaceholderRoute extends StatelessWidget {
  const _PlaceholderRoute();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('placeholder')),
      );
}
