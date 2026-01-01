import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../models/affiliate_product.dart';

class SearchService {
  SearchService(this.dio);

  final Dio dio;

  Future<List<AffiliateProduct>> search({
    required String platform,
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    // Use mock data when useMockData is enabled
    if (AppConfig.useMockData) {
      return _getMockSearchResults(query, platform);
    }

    try {
      final res = await dio.get('/api/search', queryParameters: {
        'platform': platform,
        'query': query,
        'page': page,
        'page_size': pageSize,
      });

      if (res.statusCode == null || res.statusCode! >= 400) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: 'Failed to search products: HTTP ${res.statusCode}',
        );
      }

      final data = res.data?['data'] as List<dynamic>?;
      if (data == null) {
        return [];
      }

      return data
          .map((e) => AffiliateProduct.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/search'),
        error: 'Unexpected error: $e',
        type: DioExceptionType.unknown,
      );
    }
  }

  List<AffiliateProduct> _getMockSearchResults(String query, String platform) {
    AIRecommendation ai(double price, int seed) => AIRecommendation(
          recommendedPrice: price * (1.08 + (seed % 4) * 0.02),
          confidence: 0.72 + (seed % 3) * 0.08,
          source: 'mock_formula',
          modelVersion: 'mock-formula-v1',
          reason: 'Computed from mock competitor prices and demand signals.',
        );

    final mockProducts = [
      AffiliateProduct(
        platform: platform == 'all' ? 'lazada' : platform,
        id: 'search-1',
        title: '$query - Premium Quality Item',
        url: 'https://example.com/search1',
        affiliateUrl: 'https://example.com/aff/search1',
        price: 799,
        originalPrice: 1599,
        discount: 50,
        rating: 4.8,
        reviewCount: 3241,
        image: 'https://picsum.photos/seed/${query}1/200/200',
        ai: ai(799, 1),
      ),
      AffiliateProduct(
        platform: platform == 'all' ? 'shopee' : platform,
        id: 'search-2',
        title: '$query - Best Seller 2024',
        url: 'https://example.com/search2',
        affiliateUrl: 'https://example.com/aff/search2',
        price: 599,
        originalPrice: 999,
        discount: 40,
        rating: 4.6,
        reviewCount: 1823,
        image: 'https://picsum.photos/seed/${query}2/200/200',
        ai: ai(599, 2),
      ),
      AffiliateProduct(
        platform: platform == 'all' ? 'lazada' : platform,
        id: 'search-3',
        title: '$query - Value Pack Bundle',
        url: 'https://example.com/search3',
        affiliateUrl: 'https://example.com/aff/search3',
        price: 449,
        originalPrice: 899,
        discount: 50,
        rating: 4.5,
        reviewCount: 982,
        image: 'https://picsum.photos/seed/${query}3/200/200',
        ai: ai(449, 3),
      ),
      AffiliateProduct(
        platform: platform == 'all' ? 'shopee' : platform,
        id: 'search-4',
        title: '$query - Limited Edition',
        url: 'https://example.com/search4',
        affiliateUrl: 'https://example.com/aff/search4',
        price: 1299,
        originalPrice: 2499,
        discount: 48,
        rating: 4.9,
        reviewCount: 5621,
        image: 'https://picsum.photos/seed/${query}4/200/200',
        ai: ai(1299, 4),
      ),
      AffiliateProduct(
        platform: platform == 'all' ? 'lazada' : platform,
        id: 'search-5',
        title: '$query - Starter Kit',
        url: 'https://example.com/search5',
        affiliateUrl: 'https://example.com/aff/search5',
        price: 299,
        originalPrice: 599,
        discount: 50,
        rating: 4.3,
        reviewCount: 742,
        image: 'https://picsum.photos/seed/${query}5/200/200',
        ai: ai(299, 5),
      ),
      AffiliateProduct(
        platform: platform == 'all' ? 'shopee' : platform,
        id: 'search-6',
        title: '$query - Pro Version',
        url: 'https://example.com/search6',
        affiliateUrl: 'https://example.com/aff/search6',
        price: 1899,
        originalPrice: 3299,
        discount: 42,
        rating: 4.7,
        reviewCount: 2134,
        image: 'https://picsum.photos/seed/${query}6/200/200',
        ai: ai(1899, 6),
      ),
    ];

    // Simulate network delay
    return mockProducts;
  }
}
