import 'package:baryabest_app/features/home/home_notifier.dart';
import 'package:baryabest_app/services/home_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_notifier_test.mocks.dart';

@GenerateMocks([HomeService])
void main() {
  late MockHomeService mockHomeService;
  late HomeNotifier homeNotifier;

  setUp(() {
    mockHomeService = MockHomeService();
    homeNotifier = HomeNotifier(mockHomeService);
  });

  group('HomeNotifier', () {
    test('initial state is correct', () {
      expect(homeNotifier.state.loading, false);
      expect(homeNotifier.state.sections, isEmpty);
      expect(homeNotifier.state.error, isNull);
    });

    test('load sets loading state and updates with sections', () async {
      // Arrange
      final sections = [
        const HomeSection(title: 'Best Deals', items: ['item1', 'item2']),
        const HomeSection(title: 'Trending', items: ['item3']),
      ];

      when(mockHomeService.fetchHome()).thenAnswer((_) async => sections);

      // Act
      await homeNotifier.load();

      // Assert
      expect(homeNotifier.state.loading, false);
      expect(homeNotifier.state.sections.length, 2);
      expect(homeNotifier.state.sections[0].title, 'Best Deals');
      expect(homeNotifier.state.sections[1].title, 'Trending');
      expect(homeNotifier.state.error, isNull);
    });

    test('load handles error correctly', () async {
      // Arrange
      when(mockHomeService.fetchHome()).thenThrow(Exception('Server error'));

      // Act
      await homeNotifier.load();

      // Assert
      expect(homeNotifier.state.loading, false);
      expect(homeNotifier.state.error, contains('Server error'));
      expect(homeNotifier.state.sections, isEmpty);
    });

    test('load clears previous error on new load', () async {
      // Arrange - First call fails
      when(mockHomeService.fetchHome()).thenThrow(Exception('Error'));
      await homeNotifier.load();
      expect(homeNotifier.state.error, isNotNull);

      // Arrange - Second call succeeds
      when(mockHomeService.fetchHome()).thenAnswer((_) async => []);

      // Act
      await homeNotifier.load();

      // Assert
      expect(homeNotifier.state.error, isNull);
    });

    test('load replaces sections on each call', () async {
      // Arrange - First load
      final firstSections = [
        const HomeSection(title: 'Section 1', items: []),
      ];
      when(mockHomeService.fetchHome()).thenAnswer((_) async => firstSections);
      await homeNotifier.load();
      expect(homeNotifier.state.sections.length, 1);

      // Arrange - Second load with different data
      final secondSections = [
        const HomeSection(title: 'New Section A', items: []),
        const HomeSection(title: 'New Section B', items: []),
      ];
      when(mockHomeService.fetchHome()).thenAnswer((_) async => secondSections);

      // Act
      await homeNotifier.load();

      // Assert
      expect(homeNotifier.state.sections.length, 2);
      expect(homeNotifier.state.sections[0].title, 'New Section A');
    });
  });

  group('HomeState', () {
    test('copyWith creates new state with updated values', () {
      const original = HomeState();
      final updated = original.copyWith(
        loading: true,
        error: 'Test error',
      );

      expect(updated.loading, true);
      expect(updated.error, 'Test error');
      expect(updated.sections, isEmpty); // Unchanged
    });

    test('copyWith preserves values when not specified', () {
      const original = HomeState(
        loading: true,
        sections: [HomeSection(title: 'Test', items: [])],
      );
      final updated = original.copyWith(error: 'New error');

      expect(updated.loading, true);
      expect(updated.sections.length, 1);
      expect(updated.error, 'New error');
    });

    test('copyWith can clear error by passing null', () {
      const original = HomeState(error: 'Previous error');
      final updated = original.copyWith();

      expect(updated.error, isNull);
    });
  });
}
