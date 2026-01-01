import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import '../models/lowest_price_recommendation.dart';

/// Service for fetching AI Lowest Price Recommendations
/// 
/// Fetches grouped product recommendations where the lowest price
/// across Lazada, Shopee, and TikTokShop is identified.
class LowestPriceService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Fetch lowest price recommendations from API
  /// Falls back to mock data if API is unavailable
  Future<List<LowestPriceRecommendation>> getRecommendations({
    int limit = 20,
    String? category,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/recommendations/lowest',
        queryParameters: {
          'limit': limit,
          if (category != null) 'category': category,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>? ?? [];
        
        return data
            .map((item) => LowestPriceRecommendation.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Fall through to mock data
    }

    // Return mock data for demo/offline mode
    return _generateMockRecommendations(limit);
  }

  /// Generate mock recommendations for demo purposes
  List<LowestPriceRecommendation> _generateMockRecommendations(int limit) {
    final random = Random(42); // Fixed seed for consistent demo
    final recommendations = <LowestPriceRecommendation>[];

    const products = [
      _MockProduct('Apple AirPods Pro 2nd Generation', 'airpods-pro-2', 14990, 'https://via.placeholder.com/300x300/1a1a2e/FFFFFF.png?text=AirPods'),
      _MockProduct('Samsung Galaxy Buds2 Pro', 'galaxy-buds2-pro', 9990, 'https://via.placeholder.com/300x300/1a1a2e/FFFFFF.png?text=Galaxy+Buds'),
      _MockProduct('Xiaomi Redmi Note 13 Pro 5G', 'redmi-note-13-pro', 15990, 'https://via.placeholder.com/300x300/ff6600/FFFFFF.png?text=Redmi+13'),
      _MockProduct('Anker PowerCore 20000mAh Power Bank', 'anker-powercore-20000', 2499, 'https://via.placeholder.com/300x300/2d3436/FFFFFF.png?text=Anker'),
      _MockProduct('JBL Flip 6 Portable Bluetooth Speaker', 'jbl-flip-6', 6995, 'https://via.placeholder.com/300x300/ff6b00/FFFFFF.png?text=JBL+Flip'),
      _MockProduct('Logitech G Pro X Superlight Mouse', 'logitech-gpro-superlight', 7495, 'https://via.placeholder.com/300x300/00b4d8/FFFFFF.png?text=Logitech'),
      _MockProduct('Sony WH-1000XM5 Headphones', 'sony-wh1000xm5', 19990, 'https://via.placeholder.com/300x300/1a1a2e/FFFFFF.png?text=Sony+WH'),
      _MockProduct('Nintendo Switch OLED Model', 'switch-oled', 17995, 'https://via.placeholder.com/300x300/e60012/FFFFFF.png?text=Switch'),
      _MockProduct('Kindle Paperwhite 11th Gen', 'kindle-paperwhite-11', 7490, 'https://via.placeholder.com/300x300/333333/FFFFFF.png?text=Kindle'),
      _MockProduct('Dyson V15 Detect Vacuum', 'dyson-v15', 34990, 'https://via.placeholder.com/300x300/8b4513/FFFFFF.png?text=Dyson'),
      _MockProduct('Apple Watch Series 9 GPS 45mm', 'apple-watch-s9', 24990, 'https://via.placeholder.com/300x300/1a1a2e/FFFFFF.png?text=Apple+Watch'),
      _MockProduct('Bose QuietComfort Ultra Earbuds', 'bose-qc-ultra', 17990, 'https://via.placeholder.com/300x300/1a1a2e/FFFFFF.png?text=Bose+QC'),
      _MockProduct('Samsung 65" QLED 4K Smart TV', 'samsung-qled-65', 54990, 'https://via.placeholder.com/300x300/1428a0/FFFFFF.png?text=Samsung+TV'),
      _MockProduct('DJI Mini 3 Pro Drone', 'dji-mini-3-pro', 42990, 'https://via.placeholder.com/300x300/333333/FFFFFF.png?text=DJI+Mini'),
      _MockProduct('GoPro HERO12 Black', 'gopro-hero12', 24990, 'https://via.placeholder.com/300x300/0085ca/FFFFFF.png?text=GoPro'),
    ];

    const platforms = ['lazada', 'shopee', 'tiktok'];

    for (int i = 0; i < min(limit, products.length); i++) {
      final product = products[i];
      
      // Generate random prices for each platform
      final prices = <String, double>{};
      for (final platform in platforms) {
        // Random variation: -15% to +20%
        final variation = (random.nextDouble() * 0.35) - 0.15;
        prices[platform] = (product.basePrice * (1 + variation)).roundToDouble();
      }

      // Ensure one platform is clearly cheaper (for demo)
      final winnerPlatform = platforms[random.nextInt(platforms.length)];
      prices[winnerPlatform] = (product.basePrice * 0.85).roundToDouble();

      // Sort to find winner
      final sortedPlatforms = platforms.toList()
        ..sort((a, b) => prices[a]!.compareTo(prices[b]!));
      
      final lowestPlatform = sortedPlatforms[0];
      final lowestPrice = prices[lowestPlatform]!;
      final nextLowestPrice = prices[sortedPlatforms[1]]!;
      final highestPrice = prices[sortedPlatforms[2]]!;

      final savings = nextLowestPrice - lowestPrice;
      final savingsPercent = ((highestPrice - lowestPrice) / highestPrice) * 100;

      recommendations.add(LowestPriceRecommendation(
        groupId: product.groupId,
        winner: WinnerProduct(
          platform: lowestPlatform,
          id: '$lowestPlatform-${product.groupId}',
          title: product.title,
          price: lowestPrice,
          originalPrice: (lowestPrice * 1.25).roundToDouble(),
          image: product.image,
          url: 'https://$lowestPlatform.com.ph/product/${product.groupId}',
          affiliateUrl: 'https://$lowestPlatform.com.ph/aff/${product.groupId}',
          rating: 4.0 + random.nextDouble(),
          reviewCount: random.nextInt(5000) + 50,
        ),
        comparison: PlatformComparison(
          lazada: prices['lazada'],
          shopee: prices['shopee'],
          tiktok: prices['tiktok'],
        ),
        platformProducts: {
          for (final platform in platforms)
            platform: PlatformProduct(
              platform: platform,
              id: '$platform-${product.groupId}',
              price: prices[platform]!,
              url: 'https://$platform.com.ph/product/${product.groupId}',
              affiliateUrl: 'https://$platform.com.ph/aff/${product.groupId}',
            ),
        },
        savings: savings,
        savingsPercent: savingsPercent,
        platformsCompared: 3,
        recommendationReason: _buildReason(lowestPlatform, savings, savingsPercent),
      ));
    }

    // Sort by savings descending
    recommendations.sort((a, b) => b.savings.compareTo(a.savings));

    return recommendations;
  }

  String _buildReason(String platform, double savings, double savingsPercent) {
    final platformName = _platformDisplayName(platform);
    if (savings > 0) {
      return '$platformName offers the lowest price, saving you ₱${savings.toStringAsFixed(0)} (${savingsPercent.toStringAsFixed(0)}% less than other platforms)';
    }
    return '$platformName offers the best available price for this product';
  }

  String _platformDisplayName(String platform) {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'Lazada';
      case 'shopee':
        return 'Shopee';
      case 'tiktok':
        return 'TikTok Shop';
      default:
        return platform;
    }
  }
}

class _MockProduct {
  final String title;
  final String groupId;
  final double basePrice;
  final String image;

  const _MockProduct(this.title, this.groupId, this.basePrice, this.image);
}
