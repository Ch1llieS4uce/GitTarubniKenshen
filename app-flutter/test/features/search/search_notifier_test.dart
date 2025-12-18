import 'package:baryabest_app/features/search/search_notifier.dart';
import 'package:baryabest_app/models/affiliate_product.dart';
import 'package:baryabest_app/services/search_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'search_notifier_test.mocks.dart';

@GenerateMocks([SearchService])
void main() {
  late MockSearchService mockSearchService;
  late SearchNotifier searchNotifier;

  setUp(() {
    mockSearchService = MockSearchService();
    searchNotifier = SearchNotifier(mockSearchService);
  });

  group('SearchNotifier', () {
    test('initial state is correct', () {
      expect(searchNotifier.state.loading, false);
      expect(searchNotifier.state.items, isEmpty);
      expect(searchNotifier.state.error, isNull);
      expect(searchNotifier.state.page, 1);
      expect(searchNotifier.state.endReached, false);
      expect(searchNotifier.state.platform, 'shopee');
      expect(searchNotifier.state.query, '');
    });

    test('search sets loading state and updates with results', () async {
      // Arrange
      final products = [
        const AffiliateProduct(
          platform: 'shopee',
          id: '1',
          title: 'Product 1',
          url: 'url1',
          affiliateUrl: 'aff1',
        ),
        const AffiliateProduct(
          platform: 'shopee',
          id: '2',
          title: 'Product 2',
          url: 'url2',
          affiliateUrl: 'aff2',
        ),
      ];

      when(mockSearchService.search(
        platform: anyNamed('platform'),
        query: anyNamed('query'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => products);

      // Act
      await searchNotifier.search('lazada', 'laptop');

      // Assert
      expect(searchNotifier.state.loading, false);
      expect(searchNotifier.state.items.length, 2);
      expect(searchNotifier.state.platform, 'lazada');
      expect(searchNotifier.state.query, 'laptop');
      expect(searchNotifier.state.page, 1);
      expect(searchNotifier.state.endReached, false);
      expect(searchNotifier.state.error, isNull);
    });

    test('search sets endReached when results are empty', () async {
      // Arrange
      when(mockSearchService.search(
        platform: anyNamed('platform'),
        query: anyNamed('query'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => []);

      // Act
      await searchNotifier.search('tiktok', 'shoes');

      // Assert
      expect(searchNotifier.state.items, isEmpty);
      expect(searchNotifier.state.endReached, true);
    });

    test('search handles error correctly', () async {
      // Arrange
      when(mockSearchService.search(
        platform: anyNamed('platform'),
        query: anyNamed('query'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).thenThrow(Exception('Network error'));

      // Act
      await searchNotifier.search('shopee', 'bag');

      // Assert
      expect(searchNotifier.state.loading, false);
      expect(searchNotifier.state.error, contains('Network error'));
      expect(searchNotifier.state.items, isEmpty);
    });

    test('loadMore appends new results to existing items', () async {
      // Arrange - First load
      final firstPage = [
        const AffiliateProduct(
          platform: 'shopee',
          id: '1',
          title: 'Product 1',
          url: 'url1',
          affiliateUrl: 'aff1',
        ),
      ];
      final secondPage = [
        const AffiliateProduct(
          platform: 'shopee',
          id: '2',
          title: 'Product 2',
          url: 'url2',
          affiliateUrl: 'aff2',
        ),
      ];

      when(mockSearchService.search(
        platform: anyNamed('platform'),
        query: anyNamed('query'),
        page: 1,
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => firstPage);

      when(mockSearchService.search(
        platform: anyNamed('platform'),
        query: anyNamed('query'),
        page: 2,
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => secondPage);

      // Act
      await searchNotifier.search('shopee', 'phone');
      await searchNotifier.loadMore();

      // Assert
      expect(searchNotifier.state.items.length, 2);
      expect(searchNotifier.state.page, 2);
    });

    test('loadMore does nothing when endReached is true', () async {
      // Arrange
      when(mockSearchService.search(
        platform: anyNamed('platform'),
        query: anyNamed('query'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => []);

      await searchNotifier.search('shopee', 'test');
      expect(searchNotifier.state.endReached, true);

      // Act
      await searchNotifier.loadMore();

      // Assert - service should only be called once (for initial search)
      verify(mockSearchService.search(
        platform: anyNamed('platform'),
        query: anyNamed('query'),
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).called(1);
    });

    test('loadMore sets endReached when no more results', () async {
      // Arrange
      final firstPage = [
        const AffiliateProduct(
          platform: 'shopee',
          id: '1',
          title: 'Product',
          url: 'url',
          affiliateUrl: 'aff',
        ),
      ];

      when(mockSearchService.search(
        platform: anyNamed('platform'),
        query: anyNamed('query'),
        page: 1,
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => firstPage);

      when(mockSearchService.search(
        platform: anyNamed('platform'),
        query: anyNamed('query'),
        page: 2,
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => []);

      // Act
      await searchNotifier.search('shopee', 'test');
      await searchNotifier.loadMore();

      // Assert
      expect(searchNotifier.state.endReached, true);
    });
  });

  group('SearchState', () {
    test('copyWith creates new state with updated values', () {
      const original = SearchState();
      final updated = original.copyWith(
        loading: true,
        platform: 'lazada',
        query: 'laptop',
      );

      expect(updated.loading, true);
      expect(updated.platform, 'lazada');
      expect(updated.query, 'laptop');
      expect(updated.items, isEmpty); // Unchanged
      expect(updated.page, 1); // Unchanged
    });

    test('copyWith preserves values when not specified', () {
      const original = SearchState(
        loading: true,
        page: 5,
        platform: 'tiktok',
      );
      final updated = original.copyWith(query: 'new query');

      expect(updated.loading, true);
      expect(updated.page, 5);
      expect(updated.platform, 'tiktok');
      expect(updated.query, 'new query');
    });
  });
}
