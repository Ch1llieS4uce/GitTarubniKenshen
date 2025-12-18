import 'package:baryabest_app/models/affiliate_product.dart';
import 'package:baryabest_app/services/search_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'search_service_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late SearchService searchService;

  setUp(() {
    mockDio = MockDio();
    searchService = SearchService(mockDio);
  });

  group('SearchService', () {
    test('search returns list of products on success', () async {
      // Arrange
      final responseData = {
        'data': [
          {
            'platform': 'shopee',
            'platform_product_id': '12345',
            'title': 'Test Product',
            'price': 999.99,
            'url': 'https://shopee.ph/product',
            'affiliate_url': 'https://affiliate.shopee.ph/product',
          },
          {
            'platform': 'shopee',
            'platform_product_id': '67890',
            'title': 'Another Product',
            'price': 499.99,
            'url': 'https://shopee.ph/product2',
            'affiliate_url': 'https://affiliate.shopee.ph/product2',
          },
        ],
      };

      when(mockDio.get(
        '/api/search',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/search'),
          ));

      // Act
      final results = await searchService.search(
        platform: 'shopee',
        query: 'laptop',
        page: 1,
        pageSize: 20,
      );

      // Assert
      expect(results, isA<List<AffiliateProduct>>());
      expect(results.length, 2);
      expect(results[0].title, 'Test Product');
      expect(results[1].title, 'Another Product');

      verify(mockDio.get(
        '/api/search',
        queryParameters: {
          'platform': 'shopee',
          'query': 'laptop',
          'page': 1,
          'page_size': 20,
        },
      )).called(1);
    });

    test('search returns empty list when data is null', () async {
      // Arrange
      when(mockDio.get(
        '/api/search',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {'data': null},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/search'),
          ));

      // Act
      final results = await searchService.search(
        platform: 'lazada',
        query: 'phone',
      );

      // Assert
      expect(results, isEmpty);
    });

    test('search throws DioException on HTTP error', () async {
      // Arrange
      when(mockDio.get(
        '/api/search',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {'error': 'Bad request'},
            statusCode: 400,
            requestOptions: RequestOptions(path: '/api/search'),
          ));

      // Act & Assert
      expect(
        () => searchService.search(platform: 'tiktok', query: 'shoes'),
        throwsA(isA<DioException>()),
      );
    });

    test('search rethrows DioException from network error', () async {
      // Arrange
      when(mockDio.get(
        '/api/search',
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/api/search'),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timeout',
      ));

      // Act & Assert
      expect(
        () => searchService.search(platform: 'shopee', query: 'bag'),
        throwsA(isA<DioException>()),
      );
    });

    test('search uses default pagination values', () async {
      // Arrange
      when(mockDio.get(
        '/api/search',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {'data': []},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/search'),
          ));

      // Act
      await searchService.search(platform: 'shopee', query: 'watch');

      // Assert
      verify(mockDio.get(
        '/api/search',
        queryParameters: {
          'platform': 'shopee',
          'query': 'watch',
          'page': 1,
          'page_size': 20,
        },
      )).called(1);
    });
  });
}
