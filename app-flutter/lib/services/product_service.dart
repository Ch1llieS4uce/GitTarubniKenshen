import 'dart:math';
import 'package:dio/dio.dart';
import '../models/fixed_product.dart';

/// Product Service using the EXACT fixed JSON schema
/// 
/// Fetches products and recommendations from the API,
/// with mock data fallback for demo mode.
class ProductService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Fetch products with optional filtering
  Future<List<FixedProduct>> getProducts({
    String? platform,
    String? category,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/v1/products',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (platform != null) 'platform': platform,
          if (category != null) 'category': category,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>? ?? [];
        return data
            .map((item) => FixedProduct.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Fall through to mock data
    }

    return _generateMockProducts(platform: platform, limit: limit, offset: offset);
  }

  /// Fetch lowest price recommendations
  Future<List<LowestPriceRecommendation>> getLowestPriceRecommendations({
    int limit = 20,
    int offset = 0,
    String? category,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/v1/recommendations/lowest',
        queryParameters: {
          'limit': limit,
          'offset': offset,
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

    return _generateMockRecommendations(limit: limit);
  }

  /// Fetch a single product by ID
  Future<FixedProduct?> getProduct(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/v1/products/$id');

      if (response.statusCode == 200) {
        return FixedProduct.fromJson(response.data['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      // Return null on error
    }

    return null;
  }

  /// Generate mock products following the EXACT fixed schema
  List<FixedProduct> _generateMockProducts({
    String? platform,
    int limit = 50,
    int offset = 0,
  }) {
    final random = Random(42 + offset);
    final products = <FixedProduct>[];
    
    const platforms = ['lazada', 'shopee', 'tiktokshop'];
    final targetPlatforms = platform != null ? [platform] : platforms;

    const templates = [
      _ProductTemplate('Apple AirPods Pro 2nd Generation', 'Electronics', 14990, 'airpods'),
      _ProductTemplate('Samsung Galaxy Buds2 Pro', 'Electronics', 9990, 'galaxybuds'),
      _ProductTemplate('Xiaomi Redmi Note 13 Pro 5G', 'Mobile Phones', 15990, 'redmi13'),
      _ProductTemplate('Anker PowerCore 20000mAh Power Bank', 'Electronics', 2499, 'anker'),
      _ProductTemplate('JBL Flip 6 Portable Bluetooth Speaker', 'Electronics', 6995, 'jblflip'),
      _ProductTemplate('Logitech G Pro X Superlight Mouse', 'Computer Accessories', 7495, 'logitechg'),
      _ProductTemplate('Sony WH-1000XM5 Headphones', 'Electronics', 19990, 'sonywh'),
      _ProductTemplate('Nintendo Switch OLED Model', 'Gaming', 17995, 'switcholed'),
      _ProductTemplate('Kindle Paperwhite 11th Gen', 'Electronics', 7490, 'kindle'),
      _ProductTemplate('Dyson V15 Detect Vacuum', 'Home Appliances', 34990, 'dyson'),
      _ProductTemplate('Apple Watch Series 9 GPS 45mm', 'Wearables', 24990, 'applewatch'),
      _ProductTemplate('Bose QuietComfort Ultra Earbuds', 'Electronics', 17990, 'boseqc'),
      _ProductTemplate('Samsung 65" QLED 4K Smart TV', 'Electronics', 54990, 'samsungtv'),
      _ProductTemplate('DJI Mini 3 Pro Drone', 'Electronics', 42990, 'djimini'),
      _ProductTemplate('GoPro HERO12 Black', 'Electronics', 24990, 'gopro'),
      _ProductTemplate('iPhone 15 Pro Max 256GB', 'Mobile Phones', 74990, 'iphone15'),
      _ProductTemplate('MacBook Air M3 15-inch', 'Computers', 79990, 'macbookair'),
      _ProductTemplate('iPad Pro 12.9 M2', 'Tablets', 69990, 'ipadpro'),
      _ProductTemplate('Samsung Galaxy S24 Ultra', 'Mobile Phones', 69990, 'galaxys24'),
      _ProductTemplate('ASUS ROG Zephyrus G14', 'Computers', 89990, 'rogzephyrus'),
    ];

    int count = 0;
    int templateIndex = offset;
    
    while (count < limit) {
      final template = templates[templateIndex % templates.length];
      
      for (final plat in targetPlatforms) {
        if (count >= limit) break;
        
        final product = _createMockProduct(
          template: template,
          platform: plat,
          index: templateIndex,
          random: random,
        );
        products.add(product);
        count++;
      }
      
      templateIndex++;
    }

    return products;
  }

  FixedProduct _createMockProduct({
    required _ProductTemplate template,
    required String platform,
    required int index,
    required Random random,
  }) {
    // Price variation per platform
    final priceVariation = (random.nextDouble() * 0.35) - 0.15;
    var price = (template.basePrice * (1 + priceVariation)).roundToDouble();
    
    // Make one platform clearly cheaper for demo
    if (platform == ['lazada', 'shopee', 'tiktokshop'][index % 3]) {
      price = (template.basePrice * 0.85).roundToDouble();
    }

    final originalPrice = (price * 1.25).roundToDouble();
    final discountPct = (((originalPrice - price) / originalPrice) * 100).round();
    final rating = 4.0 + random.nextDouble();
    final reviewCount = random.nextInt(10000) + 50;
    final sales = random.nextInt(50000) + 100;

    // AI recommendation
    final competitorAvg = (template.basePrice * 1.05).roundToDouble();
    final minPrice = (template.basePrice * 0.80).roundToDouble();
    final demandFactor = 0.5 + (random.nextDouble() * 0.5);
    const alpha = 0.65;
    const beta = 0.35;
    const gamma = 0.05;
    
    final recommendedPrice = (alpha * competitorAvg) + (beta * minPrice) + (gamma * competitorAvg * demandFactor);
    final confidence = 0.75 + (random.nextDouble() * 0.20);
    final recommendedSavings = price > recommendedPrice ? price - recommendedPrice : 0.0;

    final groupId = _generateGroupId(template.name, index);
    final productId = _generateProductId(platform, groupId);

    return FixedProduct(
      id: productId,
      groupId: groupId,
      platform: platform,
      title: _generateTitle(template.name, platform, index),
      category: template.category,
      price: price,
      originalPrice: originalPrice,
      discountPct: discountPct,
      rating: double.parse(rating.toStringAsFixed(1)),
      reviewCount: reviewCount,
      sales: sales,
      imageUrl: _getProductImageUrl(template.imageSeed, template.category),
      thumbnailUrl: _getProductThumbnailUrl(template.imageSeed, template.category),
      url: _generateUrl(platform, productId),
      aiRecommendation: AiRecommendation(
        recommendedPrice: double.parse(recommendedPrice.toStringAsFixed(2)),
        confidence: double.parse(confidence.toStringAsFixed(2)),
        recommendedSavings: double.parse(recommendedSavings.toStringAsFixed(2)),
        modelVersion: 'v2.1.0',
        explain: AiExplain(
          competitorAvg: competitorAvg,
          minPrice: minPrice,
          demandFactor: double.parse(demandFactor.toStringAsFixed(2)),
          alpha: alpha,
          beta: beta,
          gamma: gamma,
          clampApplied: recommendedPrice < minPrice,
          reason: _generateReason(platform, price, recommendedPrice),
        ),
      ),
      meta: ProductMeta(
        dataSource: 'mock_api',
        lastUpdated: DateTime.now().toIso8601String(),
        isDynamic: true,
      ),
    );
  }

  String _generateGroupId(String name, int index) {
    final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final variant = index ~/ 20;
    return variant > 0 ? '$slug-v$variant' : slug;
  }

  String _generateProductId(String platform, String groupId) {
    final prefix = platform.substring(0, 3).toUpperCase();
    final hash = groupId.hashCode.abs().toRadixString(16).padLeft(8, '0');
    return '$prefix-${hash.substring(0, min(8, hash.length))}';
  }

  String _generateTitle(String baseName, String platform, int index) {
    const suffixes = {
      'lazada': ['[Official Store]', '[Authentic]', '[Fast Delivery]'],
      'shopee': ['🔥 Hot Deal', '✨ Best Seller', '💯 Original'],
      'tiktokshop': ['| TikTok Exclusive', '| Viral Product', '| Trending'],
    };

    final variant = index ~/ 20;
    var title = baseName;
    if (variant > 0) {
      title = '$title - Variant $variant';
    }

    final platformSuffixes = suffixes[platform] ?? [''];
    final suffix = platformSuffixes[index % platformSuffixes.length];
    return '$title $suffix'.trim();
  }

  String _generateUrl(String platform, String productId) {
    switch (platform) {
      case 'lazada':
        return 'https://www.lazada.com.ph/products/$productId.html';
      case 'shopee':
        return 'https://shopee.ph/product/$productId';
      case 'tiktokshop':
        return 'https://shop.tiktok.com/view/product/$productId';
      default:
        return 'https://example.com/product/$productId';
    }
  }

  String _generateReason(String platform, double price, double recommendedPrice) {
    final platformName = {
      'lazada': 'Lazada',
      'shopee': 'Shopee',
      'tiktokshop': 'TikTok Shop',
    }[platform] ?? platform;

    if (price <= recommendedPrice) {
      return '$platformName offers a competitive price below the AI-recommended threshold.';
    }

    final diff = (price - recommendedPrice).toStringAsFixed(2);
    return 'Consider negotiating ₱$diff lower on $platformName to match AI recommendation.';
  }

  /// Get product image URL using placeholder.com with product-appropriate styling
  String _getProductImageUrl(String productSlug, String category) {
    // Use via.placeholder.com for PNG images that Android handles well
    final color = _getCategoryColor(category);
    final bgColor = _getCategoryBgColor(category);
    final text = _getProductShortName(productSlug);
    return 'https://via.placeholder.com/400x400/$bgColor/$color.png?text=$text';
  }

  String _getProductThumbnailUrl(String productSlug, String category) {
    final color = _getCategoryColor(category);
    final bgColor = _getCategoryBgColor(category);
    final text = _getProductShortName(productSlug);
    return 'https://via.placeholder.com/150x150/$bgColor/$color.png?text=$text';
  }

  String _getProductShortName(String slug) {
    // Convert slug to short display name
    final names = {
      'airpods': 'AirPods',
      'galaxybuds': 'Galaxy+Buds',
      'redmi13': 'Redmi+13',
      'anker': 'Anker',
      'jblflip': 'JBL+Flip',
      'logitechg': 'Logitech',
      'sonywh': 'Sony+WH',
      'switcholed': 'Switch',
      'kindle': 'Kindle',
      'dyson': 'Dyson',
      'applewatch': 'Apple+Watch',
      'boseqc': 'Bose+QC',
      'samsungtv': 'Samsung+TV',
      'djimini': 'DJI+Mini',
      'gopro': 'GoPro',
      'iphone15': 'iPhone+15',
      'macbookair': 'MacBook',
      'ipadpro': 'iPad+Pro',
      'galaxys24': 'Galaxy+S24',
      'rogzephyrus': 'ROG',
    };
    return names[slug] ?? slug.toUpperCase();
  }

  String _getCategoryColor(String category) {
    final colors = {
      'Electronics': 'FFFFFF',
      'Mobile Phones': 'FFFFFF',
      'Computer Accessories': 'FFFFFF',
      'Gaming': 'FFFFFF',
      'Home Appliances': 'FFFFFF',
      'Wearables': 'FFFFFF',
      'Computers': 'FFFFFF',
      'Tablets': 'FFFFFF',
    };
    return colors[category] ?? 'FFFFFF';
  }

  String _getCategoryBgColor(String category) {
    final colors = {
      'Electronics': '6366F1',
      'Mobile Phones': '3B82F6',
      'Computer Accessories': '8B5CF6',
      'Gaming': '10B981',
      'Home Appliances': 'F97316',
      'Wearables': 'EC4899',
      'Computers': '6366F1',
      'Tablets': '14B8A6',
    };
    return colors[category] ?? '64748B';
  }

  /// Generate mock recommendations
  List<LowestPriceRecommendation> _generateMockRecommendations({int limit = 20}) {
    final random = Random(42);
    final recommendations = <LowestPriceRecommendation>[];
    
    const templates = [
      _ProductTemplate('Apple AirPods Pro 2nd Generation', 'Electronics', 14990, 'airpods'),
      _ProductTemplate('Samsung Galaxy Buds2 Pro', 'Electronics', 9990, 'galaxybuds'),
      _ProductTemplate('Xiaomi Redmi Note 13 Pro 5G', 'Mobile Phones', 15990, 'redmi13'),
      _ProductTemplate('Anker PowerCore 20000mAh Power Bank', 'Electronics', 2499, 'anker'),
      _ProductTemplate('JBL Flip 6 Portable Bluetooth Speaker', 'Electronics', 6995, 'jblflip'),
      _ProductTemplate('Logitech G Pro X Superlight Mouse', 'Computer Accessories', 7495, 'logitechg'),
      _ProductTemplate('Sony WH-1000XM5 Headphones', 'Electronics', 19990, 'sonywh'),
      _ProductTemplate('Nintendo Switch OLED Model', 'Gaming', 17995, 'switcholed'),
      _ProductTemplate('Kindle Paperwhite 11th Gen', 'Electronics', 7490, 'kindle'),
      _ProductTemplate('Dyson V15 Detect Vacuum', 'Home Appliances', 34990, 'dyson'),
      _ProductTemplate('Apple Watch Series 9 GPS 45mm', 'Wearables', 24990, 'applewatch'),
      _ProductTemplate('Bose QuietComfort Ultra Earbuds', 'Electronics', 17990, 'boseqc'),
      _ProductTemplate('Samsung 65" QLED 4K Smart TV', 'Electronics', 54990, 'samsungtv'),
      _ProductTemplate('DJI Mini 3 Pro Drone', 'Electronics', 42990, 'djimini'),
      _ProductTemplate('GoPro HERO12 Black', 'Electronics', 24990, 'gopro'),
    ];

    const platforms = ['lazada', 'shopee', 'tiktokshop'];

    for (var i = 0; i < min(limit, templates.length); i++) {
      final template = templates[i];
      final groupId = _generateGroupId(template.name, i);

      // Generate prices for each platform
      final prices = <String, double>{};
      final productsByPlatform = <String, FixedProduct>{};

      for (final platform in platforms) {
        final priceVariation = (random.nextDouble() * 0.35) - 0.15;
        prices[platform] = (template.basePrice * (1 + priceVariation)).roundToDouble();
      }

      // Make one platform the winner
      final winnerPlatform = platforms[random.nextInt(3)];
      prices[winnerPlatform] = (template.basePrice * 0.85).roundToDouble();

      // Create products for each platform
      for (final platform in platforms) {
        productsByPlatform[platform] = _createMockProduct(
          template: template,
          platform: platform,
          index: i,
          random: random,
        );
      }

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
        groupId: groupId,
        winner: productsByPlatform[lowestPlatform]!,
        comparison: PlatformComparison(
          lazada: prices['lazada'],
          shopee: prices['shopee'],
          tiktokshop: prices['tiktokshop'],
        ),
        platformProducts: productsByPlatform,
        savings: double.parse(savings.toStringAsFixed(2)),
        savingsPercent: double.parse(savingsPercent.toStringAsFixed(1)),
        platformsCompared: 3,
        recommendationReason: _buildRecommendationReason(lowestPlatform, savings, savingsPercent),
      ));
    }

    // Sort by savings descending
    recommendations.sort((a, b) => b.savings.compareTo(a.savings));

    return recommendations;
  }

  String _buildRecommendationReason(String platform, double savings, double savingsPercent) {
    final platformName = {
      'lazada': 'Lazada',
      'shopee': 'Shopee',
      'tiktokshop': 'TikTok Shop',
    }[platform] ?? platform;

    if (savings > 0) {
      return '$platformName offers the lowest price, saving you ₱${savings.toStringAsFixed(2)} (${savingsPercent.toStringAsFixed(0)}% less than other platforms)';
    }
    return '$platformName offers the best available price for this product';
  }
}

class _ProductTemplate {
  final String name;
  final String category;
  final double basePrice;
  final String imageSeed;

  const _ProductTemplate(this.name, this.category, this.basePrice, this.imageSeed);
}
