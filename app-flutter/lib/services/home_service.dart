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
            url: 'https://www.lazada.com.ph/products/wireless-earbuds-i123456789.html',
            affiliateUrl: 'https://www.lazada.com.ph/products/wireless-earbuds-i123456789.html',
            price: 599,
            originalPrice: 1299,
            discount: 54,
            rating: 4.8,
            reviewCount: 2341,
            image: 'https://via.placeholder.com/200x200/1a1a2e/FFFFFF.png?text=Earbuds',
            ai: AIRecommendation(
              recommendedPrice: 679,
              confidence: 0.86,
              source: 'mock_formula',
              modelVersion: 'mock-formula-v1',
              reason: 'High demand signal; keep price competitive but above min margin.',
            ),
          ),
          AffiliateProduct(
            platform: 'shopee',
            id: 'mock-2',
            title: 'Smart Watch Fitness Tracker',
            url: 'https://shopee.ph/Smart-Watch-Fitness-Tracker-i.123456.789012345',
            affiliateUrl: 'https://shopee.ph/Smart-Watch-Fitness-Tracker-i.123456.789012345',
            price: 899,
            originalPrice: 1899,
            discount: 53,
            rating: 4.6,
            reviewCount: 1823,
            image: 'https://via.placeholder.com/200x200/0f4c75/FFFFFF.png?text=Smart+Watch',
            ai: AIRecommendation(
              recommendedPrice: 969,
              confidence: 0.8,
              source: 'mock_formula',
              modelVersion: 'mock-formula-v1',
              reason: 'Strong competitor pricing; small lift recommended.',
            ),
          ),
          AffiliateProduct(
            platform: 'lazada',
            id: 'mock-3',
            title: 'Portable Power Bank 20000mAh',
            url: 'https://www.lazada.com.ph/products/power-bank-20000mah-i234567890.html',
            affiliateUrl: 'https://www.lazada.com.ph/products/power-bank-20000mah-i234567890.html',
            price: 499,
            originalPrice: 999,
            discount: 50,
            rating: 4.7,
            reviewCount: 5621,
            image: 'https://via.placeholder.com/200x200/2d3436/FFFFFF.png?text=Power+Bank',
            ai: AIRecommendation(
              recommendedPrice: 529,
              confidence: 0.74,
              source: 'mock_formula',
              modelVersion: 'mock-formula-v1',
              reason: 'Moderate demand; prioritize conversion-friendly pricing.',
            ),
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
            url: 'https://shopee.ph/LED-Desk-Lamp-USB-Charging-i.234567.890123456',
            affiliateUrl: 'https://shopee.ph/LED-Desk-Lamp-USB-Charging-i.234567.890123456',
            price: 349,
            originalPrice: 699,
            discount: 50,
            rating: 4.5,
            reviewCount: 982,
            image: 'https://via.placeholder.com/200x200/f5f5dc/333333.png?text=LED+Lamp',
            ai: AIRecommendation(
              recommendedPrice: 379,
              confidence: 0.7,
              source: 'mock_formula',
              modelVersion: 'mock-formula-v1',
              reason: 'Seasonal lift detected; small increase recommended.',
            ),
          ),
          AffiliateProduct(
            platform: 'lazada',
            id: 'mock-5',
            title: 'Memory Foam Pillow Set',
            url: 'https://www.lazada.com.ph/products/memory-foam-pillow-set-i345678901.html',
            affiliateUrl: 'https://www.lazada.com.ph/products/memory-foam-pillow-set-i345678901.html',
            price: 799,
            originalPrice: 1499,
            discount: 47,
            rating: 4.9,
            reviewCount: 3421,
            image: 'https://via.placeholder.com/200x200/e8daef/333333.png?text=Pillow+Set',
            ai: AIRecommendation(
              recommendedPrice: 849,
              confidence: 0.9,
              source: 'mock_formula',
              modelVersion: 'mock-formula-v1',
              reason: 'Best seller with strong reviews; margin-friendly price.',
            ),
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
            url: 'https://shopee.ph/Unisex-Canvas-Sneakers-i.345678.901234567',
            affiliateUrl: 'https://shopee.ph/Unisex-Canvas-Sneakers-i.345678.901234567',
            price: 699,
            originalPrice: 1299,
            discount: 46,
            rating: 4.4,
            reviewCount: 2187,
            image: 'https://via.placeholder.com/200x200/ffffff/333333.png?text=Sneakers',
            ai: AIRecommendation(
              recommendedPrice: 729,
              confidence: 0.76,
              source: 'mock_formula',
              modelVersion: 'mock-formula-v1',
              reason: 'Competitive market; keep near competitor average.',
            ),
          ),
          AffiliateProduct(
            platform: 'lazada',
            id: 'mock-7',
            title: 'Minimalist Leather Wallet',
            url: 'https://www.lazada.com.ph/products/leather-wallet-minimalist-i456789012.html',
            affiliateUrl: 'https://www.lazada.com.ph/products/leather-wallet-minimalist-i456789012.html',
            price: 299,
            originalPrice: 599,
            discount: 50,
            rating: 4.7,
            reviewCount: 1543,
            image: 'https://via.placeholder.com/200x200/8b4513/FFFFFF.png?text=Wallet',
            ai: AIRecommendation(
              recommendedPrice: 319,
              confidence: 0.68,
              source: 'mock_formula',
              modelVersion: 'mock-formula-v1',
              reason: 'Lower confidence due to limited market samples.',
            ),
          ),
        ],
      ),
    ];
}
