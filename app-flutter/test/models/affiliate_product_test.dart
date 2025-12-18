import 'package:baryabest_app/models/affiliate_product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AffiliateProduct', () {
    test('fromJson creates product with all fields', () {
      final json = {
        'platform': 'shopee',
        'platform_product_id': '12345',
        'title': 'Test Product',
        'price': 999.99,
        'original_price': 1200.00,
        'discount': 16.67,
        'rating': 4.5,
        'review_count': 150,
        'seller_rating': 4.8,
        'image': 'https://example.com/image.jpg',
        'url': 'https://shopee.ph/product',
        'affiliate_url': 'https://affiliate.shopee.ph/product',
        'data_source': 'scraper',
        'ai_recommendation': {
          'recommended_price': 899.99,
          'confidence': 0.95,
          'source': 'price_history',
        },
      };

      final product = AffiliateProduct.fromJson(json);

      expect(product.platform, 'shopee');
      expect(product.id, '12345');
      expect(product.title, 'Test Product');
      expect(product.price, 999.99);
      expect(product.originalPrice, 1200.00);
      expect(product.discount, 16.67);
      expect(product.rating, 4.5);
      expect(product.reviewCount, 150);
      expect(product.sellerRating, 4.8);
      expect(product.image, 'https://example.com/image.jpg');
      expect(product.url, 'https://shopee.ph/product');
      expect(product.affiliateUrl, 'https://affiliate.shopee.ph/product');
      expect(product.dataSource, 'scraper');
      expect(product.ai, isNotNull);
      expect(product.ai!.recommendedPrice, 899.99);
      expect(product.ai!.confidence, 0.95);
      expect(product.ai!.source, 'price_history');
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'platform': 'lazada',
        'platform_product_id': '67890',
        'title': 'Minimal Product',
        'url': 'https://lazada.com/product',
        'affiliate_url': 'https://affiliate.lazada.com/product',
      };

      final product = AffiliateProduct.fromJson(json);

      expect(product.platform, 'lazada');
      expect(product.id, '67890');
      expect(product.title, 'Minimal Product');
      expect(product.price, isNull);
      expect(product.originalPrice, isNull);
      expect(product.discount, isNull);
      expect(product.rating, isNull);
      expect(product.reviewCount, isNull);
      expect(product.sellerRating, isNull);
      expect(product.image, isNull);
      expect(product.ai, isNull);
      expect(product.dataSource, isNull);
    });

    test('fromJson handles null title gracefully', () {
      final json = {
        'platform': 'tiktok',
        'platform_product_id': 'abc123',
        'title': null,
        'url': 'https://tiktok.com/product',
        'affiliate_url': 'https://affiliate.tiktok.com/product',
      };

      final product = AffiliateProduct.fromJson(json);

      expect(product.title, '');
    });

    test('fromJson handles numeric values as int or double', () {
      final json = {
        'platform': 'shopee',
        'platform_product_id': '12345',
        'title': 'Test',
        'price': 100, // int instead of double
        'review_count': 50,
        'url': 'https://shopee.ph/product',
        'affiliate_url': 'https://affiliate.shopee.ph/product',
      };

      final product = AffiliateProduct.fromJson(json);

      expect(product.price, 100.0);
      expect(product.reviewCount, 50);
    });
  });

  group('AIRecommendation', () {
    test('fromJson creates recommendation with all fields', () {
      final json = {
        'recommended_price': 499.99,
        'confidence': 0.87,
        'source': 'ml_model',
      };

      final ai = AIRecommendation.fromJson(json);

      expect(ai.recommendedPrice, 499.99);
      expect(ai.confidence, 0.87);
      expect(ai.source, 'ml_model');
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};

      final ai = AIRecommendation.fromJson(json);

      expect(ai.recommendedPrice, isNull);
      expect(ai.confidence, isNull);
      expect(ai.source, isNull);
    });
  });
}
