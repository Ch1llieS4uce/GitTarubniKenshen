/// Fixed Schema Product Model
/// 
/// This model follows the EXACT fixed JSON schema.
/// DO NOT rename, infer, or guess field names.
/// This is the single source of truth for product data.
class FixedProduct {
  final String id;
  final String groupId;
  final String platform;
  final String title;
  final String category;
  final double price;
  final double originalPrice;
  final int discountPct;
  final double rating;
  final int reviewCount;
  final int sales;
  final String imageUrl;
  final String thumbnailUrl;
  final String url;
  final AiRecommendation aiRecommendation;
  final ProductMeta meta;

  const FixedProduct({
    required this.id,
    required this.groupId,
    required this.platform,
    required this.title,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.discountPct,
    required this.rating,
    required this.reviewCount,
    required this.sales,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.url,
    required this.aiRecommendation,
    required this.meta,
  });

  factory FixedProduct.fromJson(Map<String, dynamic> json) {
    return FixedProduct(
      id: json['id'] as String? ?? '',
      groupId: json['group_id'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      discountPct: json['discount_pct'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      sales: json['sales'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      url: json['url'] as String? ?? '',
      aiRecommendation: AiRecommendation.fromJson(
        json['ai_recommendation'] as Map<String, dynamic>? ?? {},
      ),
      meta: ProductMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'platform': platform,
      'title': title,
      'category': category,
      'price': price,
      'original_price': originalPrice,
      'discount_pct': discountPct,
      'rating': rating,
      'review_count': reviewCount,
      'sales': sales,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'url': url,
      'ai_recommendation': aiRecommendation.toJson(),
      'meta': meta.toJson(),
    };
  }

  /// Get the effective image URL with fallback chain:
  /// 1. image_url
  /// 2. thumbnail_url  
  /// 3. category-based placeholder
  String get effectiveImageUrl {
    if (imageUrl.isNotEmpty) return imageUrl;
    if (thumbnailUrl.isNotEmpty) return thumbnailUrl;
    return _getCategoryPlaceholder();
  }

  /// Get category-based placeholder image
  String _getCategoryPlaceholder() {
    final categorySlug = category.replaceAll(' ', '+');
    return 'https://via.placeholder.com/400x400/1a1a2e/FFFFFF.png?text=$categorySlug';
  }

  /// Get platform display name
  String get platformDisplayName {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return 'Lazada';
      case 'shopee':
        return 'Shopee';
      case 'tiktokshop':
        return 'TikTok Shop';
      default:
        return platform;
    }
  }

  /// Validate URL against domain allowlist
  /// Returns true if URL is safe to open
  bool get hasValidUrl {
    if (url.isEmpty) return false;
    if (!url.startsWith('https://')) return false;
    
    const allowedDomains = [
      'lazada.com',
      'lazada.com.ph',
      'www.lazada.com.ph',
      'shopee.ph',
      'www.shopee.ph',
      'tiktok.com',
      'shop.tiktok.com',
      'www.tiktok.com',
    ];
    
    try {
      final uri = Uri.parse(url);
      return allowedDomains.any((domain) => 
        uri.host == domain || uri.host.endsWith('.$domain')
      );
    } catch (_) {
      return false;
    }
  }

  /// Format price consistently with ₱ symbol and 2 decimals
  String get formattedPrice => '₱${price.toStringAsFixed(2)}';

  /// Format original price
  String get formattedOriginalPrice => '₱${originalPrice.toStringAsFixed(2)}';

  /// Get the formula breakdown from AI recommendation explain
  String? get formulaBreakdown => aiRecommendation.explain.formulaBreakdown;
}

/// AI Recommendation following the exact schema
class AiRecommendation {
  final double recommendedPrice;
  final double confidence;
  final double recommendedSavings;
  final String modelVersion;
  final AiExplain explain;

  const AiRecommendation({
    required this.recommendedPrice,
    required this.confidence,
    required this.recommendedSavings,
    required this.modelVersion,
    required this.explain,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      recommendedPrice: (json['recommended_price'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      recommendedSavings: (json['recommended_savings'] as num?)?.toDouble() ?? 0.0,
      modelVersion: json['model_version'] as String? ?? '',
      explain: AiExplain.fromJson(
        json['explain'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommended_price': recommendedPrice,
      'confidence': confidence,
      'recommended_savings': recommendedSavings,
      'model_version': modelVersion,
      'explain': explain.toJson(),
    };
  }

  /// Format recommended price
  String get formattedRecommendedPrice => '₱${recommendedPrice.toStringAsFixed(2)}';

  /// Format recommended savings
  String get formattedSavings => '₱${recommendedSavings.toStringAsFixed(2)}';

  /// Get confidence as percentage
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';
}

/// AI Explain following the exact schema
class AiExplain {
  final double competitorAvg;
  final double minPrice;
  final double demandFactor;
  final double alpha;
  final double beta;
  final double gamma;
  final bool clampApplied;
  final String reason;

  const AiExplain({
    required this.competitorAvg,
    required this.minPrice,
    required this.demandFactor,
    required this.alpha,
    required this.beta,
    required this.gamma,
    required this.clampApplied,
    required this.reason,
  });

  factory AiExplain.fromJson(Map<String, dynamic> json) {
    return AiExplain(
      competitorAvg: (json['competitor_avg'] as num?)?.toDouble() ?? 0.0,
      minPrice: (json['min_price'] as num?)?.toDouble() ?? 0.0,
      demandFactor: (json['demand_factor'] as num?)?.toDouble() ?? 0.0,
      alpha: (json['alpha'] as num?)?.toDouble() ?? 0.0,
      beta: (json['beta'] as num?)?.toDouble() ?? 0.0,
      gamma: (json['gamma'] as num?)?.toDouble() ?? 0.0,
      clampApplied: json['clamp_applied'] as bool? ?? false,
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competitor_avg': competitorAvg,
      'min_price': minPrice,
      'demand_factor': demandFactor,
      'alpha': alpha,
      'beta': beta,
      'gamma': gamma,
      'clamp_applied': clampApplied,
      'reason': reason,
    };
  }

  /// Get the formula string
  String get formulaString => 'P = α×Pc + β×Pmin + γ×Pc×Df';

  /// Get the formula breakdown with values
  String get formulaBreakdown {
    final alphaComp = alpha * competitorAvg;
    final betaComp = beta * minPrice;
    final gammaComp = gamma * competitorAvg * demandFactor;
    
    return 'P = ${alpha.toStringAsFixed(2)}×₱${competitorAvg.toStringAsFixed(0)} + '
           '${beta.toStringAsFixed(2)}×₱${minPrice.toStringAsFixed(0)} + '
           '${gamma.toStringAsFixed(2)}×₱${competitorAvg.toStringAsFixed(0)}×${demandFactor.toStringAsFixed(2)}\n'
           'P = ₱${alphaComp.toStringAsFixed(2)} + ₱${betaComp.toStringAsFixed(2)} + ₱${gammaComp.toStringAsFixed(2)}';
  }
}

/// Product Meta following the exact schema
class ProductMeta {
  final String dataSource;
  final String lastUpdated;
  final bool isDynamic;

  const ProductMeta({
    required this.dataSource,
    required this.lastUpdated,
    required this.isDynamic,
  });

  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    return ProductMeta(
      dataSource: json['data_source'] as String? ?? 'mock_api',
      lastUpdated: json['last_updated'] as String? ?? '',
      isDynamic: json['is_dynamic'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data_source': dataSource,
      'last_updated': lastUpdated,
      'is_dynamic': isDynamic,
    };
  }
}

/// Lowest Price Recommendation response following exact schema
class LowestPriceRecommendation {
  final String groupId;
  final FixedProduct winner;
  final PlatformComparison comparison;
  final Map<String, FixedProduct> platformProducts;
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
    final platformProducts = <String, FixedProduct>{};
    platformProductsRaw.forEach((key, value) {
      if (value != null) {
        platformProducts[key] = FixedProduct.fromJson(value as Map<String, dynamic>);
      }
    });

    return LowestPriceRecommendation(
      groupId: json['group_id'] as String? ?? '',
      winner: FixedProduct.fromJson(json['winner'] as Map<String, dynamic>? ?? {}),
      comparison: PlatformComparison.fromJson(json['comparison'] as Map<String, dynamic>? ?? {}),
      platformProducts: platformProducts,
      savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
      savingsPercent: (json['savings_percent'] as num?)?.toDouble() ?? 0.0,
      platformsCompared: json['platforms_compared'] as int? ?? 0,
      recommendationReason: json['recommendation_reason'] as String? ?? '',
    );
  }

  /// Format savings
  String get formattedSavings => '₱${savings.toStringAsFixed(2)}';

  /// Check if this product has significant savings
  bool get hasSignificantSavings => savings >= 50;
}

/// Platform price comparison
class PlatformComparison {
  final double? lazada;
  final double? shopee;
  final double? tiktokshop;

  const PlatformComparison({
    this.lazada,
    this.shopee,
    this.tiktokshop,
  });

  factory PlatformComparison.fromJson(Map<String, dynamic> json) {
    return PlatformComparison(
      lazada: (json['lazada'] as num?)?.toDouble(),
      shopee: (json['shopee'] as num?)?.toDouble(),
      tiktokshop: (json['tiktokshop'] as num?)?.toDouble(),
    );
  }

  /// Get price for a specific platform
  double? priceFor(String platform) {
    switch (platform.toLowerCase()) {
      case 'lazada':
        return lazada;
      case 'shopee':
        return shopee;
      case 'tiktokshop':
        return tiktokshop;
      default:
        return null;
    }
  }

  /// Get all available platform prices as a map
  Map<String, double> get availablePrices {
    final prices = <String, double>{};
    if (lazada != null) prices['lazada'] = lazada!;
    if (shopee != null) prices['shopee'] = shopee!;
    if (tiktokshop != null) prices['tiktokshop'] = tiktokshop!;
    return prices;
  }

  /// Format price for a platform
  String? formattedPriceFor(String platform) {
    final price = priceFor(platform);
    if (price == null) return null;
    return '₱${price.toStringAsFixed(2)}';
  }
}
