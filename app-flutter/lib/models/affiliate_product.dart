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
  });

  factory AffiliateProduct.fromJson(Map<String, dynamic> json) {
    final aiJson = json['ai_recommendation'] as Map<String, dynamic>?;
    return AffiliateProduct(
      platform: json['platform'] as String,
      id: json['platform_product_id'] as String,
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
}

class AIRecommendation {
  const AIRecommendation({
    this.recommendedPrice,
    this.confidence,
    this.source,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) =>
      AIRecommendation(
        recommendedPrice: (json['recommended_price'] as num?)?.toDouble(),
        confidence: (json['confidence'] as num?)?.toDouble(),
        source: json['source'] as String?,
      );

  final double? recommendedPrice;
  final double? confidence;
  final String? source;
}
