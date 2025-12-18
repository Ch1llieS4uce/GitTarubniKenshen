import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../models/affiliate_product.dart';

class HomeSection {
  const HomeSection({required this.title, required this.items});

  final String title;
  final List<dynamic> items; // AffiliateProduct or map for trending searches

  @override
  String toString() => 'HomeSection(title: $title, itemCount: ${items.length})';
}

class HomeService {
  HomeService(this.dio);

  final Dio dio;

  Future<List<HomeSection>> fetchHome() async {
    // Use mock data when useMockData is enabled
    if (AppConfig.useMockData) {
      return _getMockData();
    }

    try {
      final res = await dio.get('/api/home');

      if (res.statusCode == null || res.statusCode! >= 400) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch home data: HTTP ${res.statusCode}',
        );
      }

      final data = res.data as Map<String, dynamic>?;
      if (data == null) {
        return [];
      }

      final sections = (data['sections'] as List<dynamic>?)
              ?.map((s) {
                if (s is! Map<String, dynamic>) {
                  return null;
                }
                final title = s['title'] as String?;
                if (title == null) {
                  return null;
                }

                final items = (s['items'] as List<dynamic>?)?.map((item) {
                      if (item is Map<String, dynamic> &&
                          item.containsKey('platform')) {
                        return AffiliateProduct.fromJson(item);
                      }
                      return item;
                    }).toList() ??
                    [];
                return HomeSection(title: title, items: items);
              })
              .whereType<HomeSection>()
              .toList() ??
          [];

      return sections;
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/home'),
        error: 'Unexpected error: $e',
        type: DioExceptionType.unknown,
      );
    }
  }

  List<HomeSection> _getMockData() => [
      const HomeSection(
        title: 'Flash Deals',
        items: [
          AffiliateProduct(
            platform: 'lazada',
            id: 'mock-1',
            title: 'Wireless Bluetooth Earbuds Pro',
            url: 'https://example.com/product1',
            affiliateUrl: 'https://example.com/aff/product1',
            price: 599,
            originalPrice: 1299,
            discount: 54,
            rating: 4.8,
            reviewCount: 2341,
            image: 'https://picsum.photos/seed/earbuds/200/200',
          ),
          AffiliateProduct(
            platform: 'shopee',
            id: 'mock-2',
            title: 'Smart Watch Fitness Tracker',
            url: 'https://example.com/product2',
            affiliateUrl: 'https://example.com/aff/product2',
            price: 899,
            originalPrice: 1899,
            discount: 53,
            rating: 4.6,
            reviewCount: 1823,
            image: 'https://picsum.photos/seed/watch/200/200',
          ),
          AffiliateProduct(
            platform: 'lazada',
            id: 'mock-3',
            title: 'Portable Power Bank 20000mAh',
            url: 'https://example.com/product3',
            affiliateUrl: 'https://example.com/aff/product3',
            price: 499,
            originalPrice: 999,
            discount: 50,
            rating: 4.7,
            reviewCount: 5621,
            image: 'https://picsum.photos/seed/powerbank/200/200',
          ),
        ],
      ),
      const HomeSection(
        title: 'Trending Now',
        items: [
          {'query': 'iPhone 15 Pro Max', 'count': 12453},
          {'query': 'Gaming Laptop', 'count': 8932},
          {'query': 'Air Fryer', 'count': 7621},
          {'query': 'Mechanical Keyboard', 'count': 5432},
        ],
      ),
      const HomeSection(
        title: 'Home & Living',
        items: [
          AffiliateProduct(
            platform: 'shopee',
            id: 'mock-4',
            title: 'LED Desk Lamp with USB Charging',
            url: 'https://example.com/product4',
            affiliateUrl: 'https://example.com/aff/product4',
            price: 349,
            originalPrice: 699,
            discount: 50,
            rating: 4.5,
            reviewCount: 982,
            image: 'https://picsum.photos/seed/lamp/200/200',
          ),
          AffiliateProduct(
            platform: 'lazada',
            id: 'mock-5',
            title: 'Memory Foam Pillow Set',
            url: 'https://example.com/product5',
            affiliateUrl: 'https://example.com/aff/product5',
            price: 799,
            originalPrice: 1499,
            discount: 47,
            rating: 4.9,
            reviewCount: 3421,
            image: 'https://picsum.photos/seed/pillow/200/200',
          ),
        ],
      ),
      const HomeSection(
        title: 'Fashion',
        items: [
          AffiliateProduct(
            platform: 'shopee',
            id: 'mock-6',
            title: 'Unisex Canvas Sneakers',
            url: 'https://example.com/product6',
            affiliateUrl: 'https://example.com/aff/product6',
            price: 699,
            originalPrice: 1299,
            discount: 46,
            rating: 4.4,
            reviewCount: 2187,
            image: 'https://picsum.photos/seed/sneakers/200/200',
          ),
          AffiliateProduct(
            platform: 'lazada',
            id: 'mock-7',
            title: 'Minimalist Leather Wallet',
            url: 'https://example.com/product7',
            affiliateUrl: 'https://example.com/aff/product7',
            price: 299,
            originalPrice: 599,
            discount: 50,
            rating: 4.7,
            reviewCount: 1543,
            image: 'https://picsum.photos/seed/wallet/200/200',
          ),
        ],
      ),
    ];
}
