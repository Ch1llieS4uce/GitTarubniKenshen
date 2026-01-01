class AffiliateProduct {
  const AffiliateProduct({
    required this.platform,
    required this.id,
    required this.title,
    required this.url,
    required this.affiliateUrl,
    this.price,
    this.originalPrice,
    this.discount,
    this.rating,
    this.reviewCount,
    this.sellerRating,
    this.image,
    this.ai,
    this.dataSource,
    // Live pricing fields
    this.recommendedPrice,
    this.confidence,
    this.demandFactor,
    this.competitorAvg,
    this.modelVersion,
    this.pricingUpdatedAt,
    this.priceDirection,
  });

  factory AffiliateProduct.fromJson(Map<String, dynamic> json) {
    final aiJson = json['ai_recommendation'] as Map<String, dynamic>?;
    return AffiliateProduct(
      platform: json['platform'] as String,
      id: json['platform_product_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int?,
      sellerRating: (json['seller_rating'] as num?)?.toDouble(),
      image: json['image'] as String?,
      url: json['url'] as String? ?? '',
      affiliateUrl: json['affiliate_url'] as String? ?? '',
      ai: aiJson != null ? AIRecommendation.fromJson(aiJson) : null,
      dataSource: json['data_source'] as String?,
      // Live pricing fields
      recommendedPrice: (json['recommended_price'] as num?)?.toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble(),
      demandFactor: (json['demand_factor'] as num?)?.toDouble(),
      competitorAvg: (json['competitor_avg'] as num?)?.toDouble(),
      modelVersion: json['model_version'] as String?,
      pricingUpdatedAt: json['pricing_updated_at'] != null
          ? DateTime.tryParse(json['pricing_updated_at'] as String)
          : null,
      priceDirection: json['price_direction'] as int?,
    );
  }

  final String platform;
  final String id;
  final String title;
  final double? price;
  final double? originalPrice;
  final double? discount;
  final double? rating;
  final int? reviewCount;
  final double? sellerRating;
  final String? image;
  final String url;
  final String affiliateUrl;
  final AIRecommendation? ai;
  final String? dataSource;
  
  // Live pricing fields for dynamic updates
  final double? recommendedPrice;
  final double? confidence;
  final double? demandFactor;
  final double? competitorAvg;
  final String? modelVersion;
  final DateTime? pricingUpdatedAt;
  final int? priceDirection; // -1 = down, 0 = stable, 1 = up

  /// Get the effective recommended price (from live pricing or AI recommendation)
  double? get effectiveRecommendedPrice => 
      recommendedPrice ?? ai?.recommendedPrice;

  /// Get the effective confidence (from live pricing or AI recommendation)
  double? get effectiveConfidence => 
      confidence ?? ai?.confidence;

  /// Calculate savings compared to current price
  double? get savings {
    final recPrice = effectiveRecommendedPrice;
    if (recPrice == null || price == null) return null;
    return price! - recPrice;
  }

  /// Calculate savings percentage
  double? get savingsPercent {
    final s = savings;
    if (s == null || price == null || price == 0) return null;
    return (s / price!) * 100;
  }

  /// Whether this product has AI pricing data
  bool get hasAIPricing => effectiveRecommendedPrice != null;

  /// Create a copy with updated live pricing
  AffiliateProduct copyWithLivePricing({
    double? recommendedPrice,
    double? confidence,
    double? demandFactor,
    double? competitorAvg,
    String? modelVersion,
    DateTime? pricingUpdatedAt,
    int? priceDirection,
    double? price,
  }) {
    return AffiliateProduct(
      platform: platform,
      id: id,
      title: title,
      url: url,
      affiliateUrl: affiliateUrl,
      price: price ?? this.price,
      originalPrice: originalPrice,
      discount: discount,
      rating: rating,
      reviewCount: reviewCount,
      sellerRating: sellerRating,
      image: image,
      ai: ai,
      dataSource: dataSource,
      recommendedPrice: recommendedPrice ?? this.recommendedPrice,
      confidence: confidence ?? this.confidence,
      demandFactor: demandFactor ?? this.demandFactor,
      competitorAvg: competitorAvg ?? this.competitorAvg,
      modelVersion: modelVersion ?? this.modelVersion,
      pricingUpdatedAt: pricingUpdatedAt ?? this.pricingUpdatedAt,
      priceDirection: priceDirection ?? this.priceDirection,
    );
  }
}

class AIRecommendation {
  const AIRecommendation({
    this.recommendedPrice,
    this.confidence,
    this.source,
    this.reason,
    this.modelVersion,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) =>
      AIRecommendation(
        recommendedPrice: (json['recommended_price'] as num?)?.toDouble(),
        confidence: (json['confidence'] as num?)?.toDouble(),
        source: json['source'] as String?,
        reason: json['reason'] as String?,
        modelVersion: json['model_version'] as String?,
      );

  final double? recommendedPrice;
  final double? confidence;
  final String? source;
  final String? reason;
  final String? modelVersion;
}
