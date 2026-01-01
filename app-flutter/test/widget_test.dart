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

    // Wait for splash delay + navigation transition.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Login / Register'), findsOneWidget);
  });
}
