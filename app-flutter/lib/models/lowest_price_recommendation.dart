/// Model for AI Lowest Price Recommendation
/// 
/// Represents a product group with the lowest price winner
/// across Lazada, Shopee, and TikTokShop platforms.
class LowestPriceRecommendation {
  final String groupId;
  final WinnerProduct winner;
  final PlatformComparison comparison;
  final Map<String, PlatformProduct> platformProducts;
  final double savings;
  final double savingsPercent;
  final int platformsCompared;
  final String recommendationReason;

  const LowestPriceRecommendation({
    required this.groupId,
    required this.winner,
    required this.comparison,
    required this.platformProducts,
    required this.savings,
    required this.savingsPercent,
    required this.platformsCompared,
    required this.recommendationReason,
  });

  factory LowestPriceRecommendation.fromJson(Map<String, dynamic> json) {
    // Parse platform products
    final platformProductsRaw = json['platform_products'] as Map<String, dynamic>? ?? {};
    final platformProducts = <String, PlatformProduct>{};
    platformProductsRaw.forEach((key, value) {
      if (value != null) {
        platformProducts[key] = PlatformProduct.fromJson(value as Map<String, dynamic>);
      }
    });

    return LowestPriceRecommendation(
      groupId: json['group_id'] as String? ?? '',
      winner: WinnerProduct.fromJson(json['winner'] as Map<String, dynamic>? ?? {}),
      comparison: PlatformComparison.fromJson(json['comparison'] as Map<String, dynamic>? ?? {}),
      platformProducts: platformProducts,
      savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
      savingsPercent: (json['savings_percent'] as num?)?.toDouble() ?? 0.0,
      platformsCompared: json['platforms_compared'] as int? ?? 0,
      recommendationReason: json['recommendation_reason'] as String? ?? '',
    );
  }

  /// Get the next lowest price (for comparison)
  double? get nextLowestPrice {
    final prices = [
      comparison.lazada,
      comparison.shopee,
      comparison.tiktok,
    ].whereType<double>().where((p) => p > winner.price).toList()
      ..sort();
    
    return prices.isNotEmpty ? prices.first : null;
  }

  /// Check if this product has significant savings
  bool get hasSignificantSavings => savings >= 50;
}

/// The winning product with the lowest price
class WinnerProduct {
  final String platform;
  final String id;
  final String title;
  final double price;
  final double? originalPrice;
  final String? image;
  final String url;
  final String affiliateUrl;
  final double? rating;
  final int? reviewCount;

  const WinnerProduct({
    required this.platform,
    required this.id,
    required this.title,
    required this.price,
    this.originalPrice,
    this.image,
    required this.url,
    required this.affiliateUrl,
    this.rating,
    this.reviewCount,
  });

  factory WinnerProduct.fromJson(Map<String, dynamic> json) {
    return WinnerProduct(
      platform: json['platform'] as String? ?? '',
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      image: json['image'] as String?,
      url: json['url'] as String? ?? '',
      affiliateUrl: json['affiliate_url'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int?,
    );
  }

  /// Get the effective URL (prefer affiliate)
  String get effectiveUrl => affiliateUrl.isNotEmpty ? affiliateUrl : url;

  /// Get platform display name
  String get platformDisplayName {
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

/// Platform price comparison
class PlatformComparison {
  final double? lazada;
  final double? shopee;
  final double? tiktok;

  const PlatformComparison({
    this.lazada,
    this.shopee,
    this.tiktok,
  });

  factory PlatformComparison.fromJson(Map<String, dynamic> json) {
    return PlatformComparison(
      lazada: (json['lazada'] as num?)?.toDouble(),
      shopee: (json['shopee'] as num?)?.toDouble(),
      tiktok: (json['tiktok'] as num?)?.toDouble(),
    );
  }

  /// Get price for a specific platform
  double? priceFor(String platform) {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return lazada;
      case 'shopee':
        return shopee;
      case 'tiktok':
        return tiktok;
      default:
        return null;
    }
  }

  /// Get all available platform prices as a map
  Map<String, double> get availablePrices {
    final prices = <String, double>{};
    if (lazada != null) prices['lazada'] = lazada!;
    if (shopee != null) prices['shopee'] = shopee!;
    if (tiktok != null) prices['tiktok'] = tiktok!;
    return prices;
  }
}

/// Individual platform product info
class PlatformProduct {
  final String platform;
  final String id;
  final double price;
  final String url;
  final String affiliateUrl;

  const PlatformProduct({
    required this.platform,
    required this.id,
    required this.price,
    required this.url,
    required this.affiliateUrl,
  });

  factory PlatformProduct.fromJson(Map<String, dynamic> json) {
    return PlatformProduct(
      platform: json['platform'] as String? ?? '',
      id: json['id'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      url: json['url'] as String? ?? '',
      affiliateUrl: json['affiliate_url'] as String? ?? '',
    );
  }

  String get effectiveUrl => affiliateUrl.isNotEmpty ? affiliateUrl : url;
}
