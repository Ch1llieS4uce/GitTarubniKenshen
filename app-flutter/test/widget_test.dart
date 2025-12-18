import 'package:baryabest_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Boots into the splash screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('BARYABest'), findsWidgets);
  });
}
