import 'package:baryabest_app/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('displays splash screen with gradient background', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Verify scaffold is displayed
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify gradient container is present
      expect(find.byType(Container), findsWidgets);

      // Cancel pending timers to avoid test warnings
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('displays logo image', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Verify Image widget is present
      expect(find.byType(Image), findsOneWidget);

      // Cancel pending timers
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('displays app title text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Verify "BARYABest" title text
      expect(find.text('BARYABest'), findsOneWidget);

      // Cancel pending timers
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('has correct screen structure', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Verify column layout is used
      expect(find.byType(Column), findsWidgets);

      // Cancel pending timers
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('navigates to home screen after timer', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Initially on splash screen
      expect(find.byType(SplashScreen), findsOneWidget);

      // Wait for navigation timer (2 seconds) plus settle
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // After timer, should navigate away from splash
      expect(find.byType(SplashScreen), findsNothing);
    });
  });
}
