import 'package:baryabest_app/main.dart';
import 'package:baryabest_app/providers.dart';
import 'package:baryabest_app/services/home_service.dart';
import 'package:dio/dio.dart';
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
  testWidgets('Boots into the guest home', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeServiceProvider.overrideWithValue(_FakeHomeService()),
        ],
        child: const MyApp(),
      ),
    );

    // App starts on the device home mock (debug default); tap to open splash.
    expect(find.text('Tap to open'), findsOneWidget);
    await tester.tap(find.text('Tap to open'));
    await tester.pumpAndSettle();

    // Wait for splash delay + navigation transition.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Splash routes guests to onboarding; skip to reach the guest home.
    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to unlock more'), findsOneWidget);
  });
}
