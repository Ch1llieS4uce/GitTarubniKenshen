import 'package:baryabest_app/models/affiliate_product.dart';
import 'package:baryabest_app/services/home_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_service_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late HomeService homeService;

  setUp(() {
    mockDio = MockDio();
    homeService = HomeService(mockDio);
  });

  group('HomeService', () {
    test('fetchHome returns list of sections with products', () async {
      // Arrange
      final responseData = {
        'sections': [
          {
            'title': 'Best Deals Today',
            'items': [
              {
                'platform': 'shopee',
                'platform_product_id': '12345',
                'title': 'Hot Product',
                'price': 999.99,
                'url': 'https://shopee.ph/product',
                'affiliate_url': 'https://affiliate.shopee.ph/product',
              },
            ],
          },
          {
            'title': 'Trending Searches',
            'items': [
              {'query': 'laptop'},
              {'query': 'phone'},
            ],
          },
        ],
      };

      when(mockDio.get('/api/home')).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/home'),
          ));

      // Act
      final sections = await homeService.fetchHome();

      // Assert
      expect(sections, isA<List<HomeSection>>());
      expect(sections.length, 2);
      expect(sections[0].title, 'Best Deals Today');
      expect(sections[0].items.length, 1);
      expect(sections[0].items[0], isA<AffiliateProduct>());
      expect((sections[0].items[0] as AffiliateProduct).title, 'Hot Product');
      expect(sections[1].title, 'Trending Searches');
      expect(sections[1].items.length, 2);
    });

    test('fetchHome returns empty list when data is null', () async {
      // Arrange
      when(mockDio.get('/api/home')).thenAnswer((_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/home'),
          ));

      // Act
      final sections = await homeService.fetchHome();

      // Assert
      expect(sections, isEmpty);
    });

    test('fetchHome returns empty list when sections is null', () async {
      // Arrange
      when(mockDio.get('/api/home')).thenAnswer((_) async => Response(
            data: {'sections': null},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/home'),
          ));

      // Act
      final sections = await homeService.fetchHome();

      // Assert
      expect(sections, isEmpty);
    });

    test('fetchHome skips invalid section entries', () async {
      // Arrange
      final responseData = {
        'sections': [
          {
            'title': 'Valid Section',
            'items': [],
          },
          'invalid_section', // Not a map
          {
            'items': [], // Missing title
          },
          {
            'title': null, // Null title
            'items': [],
          },
        ],
      };

      when(mockDio.get('/api/home')).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/home'),
          ));

      // Act
      final sections = await homeService.fetchHome();

      // Assert
      expect(sections.length, 1);
      expect(sections[0].title, 'Valid Section');
    });

    test('fetchHome throws DioException on HTTP error', () async {
      // Arrange
      when(mockDio.get('/api/home')).thenAnswer((_) async => Response(
            data: {'error': 'Server error'},
            statusCode: 500,
            requestOptions: RequestOptions(path: '/api/home'),
          ));

      // Act & Assert
      expect(
        () => homeService.fetchHome(),
        throwsA(isA<DioException>()),
      );
    });

    test('fetchHome rethrows DioException from network error', () async {
      // Arrange
      when(mockDio.get('/api/home')).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/api/home'),
        type: DioExceptionType.connectionError,
        message: 'Network error',
      ));

      // Act & Assert
      expect(
        () => homeService.fetchHome(),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('HomeSection', () {
    test('toString returns formatted string', () {
      const section = HomeSection(title: 'Test Section', items: [1, 2, 3]);

      expect(
          section.toString(), 'HomeSection(title: Test Section, itemCount: 3)');
    });
  });
}
