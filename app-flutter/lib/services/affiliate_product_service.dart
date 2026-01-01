import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../models/affiliate_product.dart';

/// Response wrapper for paginated product results
class ProductPageResponse {
  const ProductPageResponse({
    required this.products,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.hasMore,
  });

  factory ProductPageResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return ProductPageResponse(
      products: data
          .map((e) => AffiliateProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      perPage: meta['per_page'] as int? ?? 50,
      total: meta['total'] as int? ?? 0,
      lastPage: meta['last_page'] as int? ?? 1,
      hasMore: meta['has_more'] as bool? ?? false,
    );
  }

  factory ProductPageResponse.empty() => const ProductPageResponse(
        products: [],
        currentPage: 1,
        perPage: 50,
        total: 0,
        lastPage: 1,
        hasMore: false,
      );

  final List<AffiliateProduct> products;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final bool hasMore;
}

/// Service for fetching affiliate products with pagination
class AffiliateProductService {
  AffiliateProductService(this.dio);

  final Dio dio;

  /// Fetch products with pagination and filtering
  ///
  /// [platform] - lazada, shopee, tiktok, or all
  /// [query] - optional search term
  /// [page] - page number (1-indexed)
  /// [limit] - items per page (max 200)
  /// [minPrice] / [maxPrice] - price filters
  /// [minRating] - minimum rating filter
  /// [sort] - relevance, price_asc, price_desc, rating, sales, newest
  Future<ProductPageResponse> fetchProducts({
    String platform = 'all',
    String? query,
    int page = 1,
    int limit = 50,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String sort = 'relevance',
  }) async {
    // Use mock data when enabled
    if (AppConfig.useMockData) {
      return _getMockProducts(
        platform: platform,
        page: page,
        limit: limit,
        query: query,
      );
    }

    try {
      final queryParams = <String, dynamic>{
        'platform': platform,
        'page': page,
        'limit': limit,
        'sort': sort,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice;
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice;
      }
      if (minRating != null) {
        queryParams['min_rating'] = minRating;
      }

      final response = await dio.get(
        '/api/affiliate-products',
        queryParameters: queryParams,
      );

      if (response.statusCode == null || response.statusCode! >= 400) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch products: HTTP ${response.statusCode}',
        );
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null || data['success'] != true) {
        return ProductPageResponse.empty();
      }

      return ProductPageResponse.fromJson(data);
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/affiliate-products'),
        error: 'Unexpected error: $e',
        type: DioExceptionType.unknown,
      );
    }
  }

  /// Fetch a single product by platform and ID
  Future<AffiliateProduct?> fetchProduct(String platform, String id) async {
    if (AppConfig.useMockData) {
      return _getMockSingleProduct(platform, id);
    }

    try {
      final response = await dio.get('/api/affiliate-products/$platform/$id');

      if (response.statusCode == null || response.statusCode! >= 400) {
        return null;
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null || data['success'] != true) {
        return null;
      }

      final productData = data['data'] as Map<String, dynamic>?;
      if (productData == null) {
        return null;
      }

      return AffiliateProduct.fromJson(productData);
    } catch (e) {
      return null;
    }
  }

  /// Generate mock products for development
  ProductPageResponse _getMockProducts({
    required String platform,
    required int page,
    required int limit,
    String? query,
  }) {
    final platforms = platform == 'all'
        ? ['lazada', 'shopee', 'tiktok']
        : [platform];

    final allProducts = <AffiliateProduct>[];
    const productsPerPlatform = 2000;

    for (final p in platforms) {
      for (var i = 0; i < productsPerPlatform; i++) {
        final id = '$p-${i + 1}';
        final basePrice = 100 + (i * 17 % 5000);
        final discount = 10 + (i % 60);
        final originalPrice = basePrice / (1 - discount / 100);

        allProducts.add(
          AffiliateProduct(
            platform: p,
            id: id,
            title: _generateProductTitle(p, i, query),
            url: 'https://example.com/$p/product/$id',
            affiliateUrl: 'https://example.com/$p/aff/$id',
            price: basePrice.toDouble(),
            originalPrice: originalPrice,
            discount: discount.toDouble(),
            rating: 3.5 + (i % 15) / 10,
            reviewCount: 100 + (i * 37 % 10000),
            sellerRating: 4.0 + (i % 10) / 10,
            image: 'https://picsum.photos/seed/$id/300/300',
            ai: AIRecommendation(
              recommendedPrice: basePrice * 1.08,
              confidence: 0.7 + (i % 25) / 100,
              source: 'mock_engine',
              modelVersion: 'v1.0',
              reason: 'Competitive pricing based on market analysis',
            ),
            dataSource: 'Mock data for development',
          ),
        );
      }
    }

    // Filter by query if provided
    var filtered = allProducts;
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = allProducts
          .where((p) => p.title.toLowerCase().contains(lowerQuery))
          .toList();
    }

    // Paginate
    final total = filtered.length;
    final start = (page - 1) * limit;
    final end = start + limit;
    final pageProducts = filtered.sublist(
      start.clamp(0, total),
      end.clamp(0, total),
    );

    return ProductPageResponse(
      products: pageProducts,
      currentPage: page,
      perPage: limit,
      total: total,
      lastPage: (total / limit).ceil(),
      hasMore: end < total,
    );
  }

  String _generateProductTitle(String platform, int index, String? query) {
    final categories = [
      'Electronics',
      'Fashion',
      'Home & Living',
      'Beauty',
      'Sports',
      'Toys',
      'Automotive',
      'Books',
    ];
    final adjectives = [
      'Premium',
      'Best Seller',
      'New',
      'Trending',
      'Sale',
      'Limited',
      'Popular',
      'Top Rated',
    ];
    final types = [
      'Gadget',
      'Accessory',
      'Set',
      'Bundle',
      'Kit',
      'Collection',
      'Pack',
      'Item',
    ];

    final category = categories[index % categories.length];
    final adjective = adjectives[index % adjectives.length];
    final type = types[index % types.length];

    if (query != null && query.isNotEmpty) {
      return '$adjective $query $type #${index + 1}';
    }
    return '$adjective $category $type #${index + 1}';
  }

  AffiliateProduct? _getMockSingleProduct(String platform, String id) {
    final index = int.tryParse(id.split('-').last) ?? 1;
    final basePrice = 100 + (index * 17 % 5000);
    final discount = 10 + (index % 60);
    final originalPrice = basePrice / (1 - discount / 100);

    return AffiliateProduct(
      platform: platform,
      id: id,
      title: _generateProductTitle(platform, index, null),
      url: 'https://example.com/$platform/product/$id',
      affiliateUrl: 'https://example.com/$platform/aff/$id',
      price: basePrice.toDouble(),
      originalPrice: originalPrice,
      discount: discount.toDouble(),
      rating: 3.5 + (index % 15) / 10,
      reviewCount: 100 + (index * 37 % 10000),
      sellerRating: 4.0 + (index % 10) / 10,
      image: 'https://picsum.photos/seed/$id/300/300',
      ai: AIRecommendation(
        recommendedPrice: basePrice * 1.08,
        confidence: 0.7 + (index % 25) / 100,
        source: 'mock_engine',
        modelVersion: 'v1.0',
        reason: 'Competitive pricing based on market analysis',
      ),
      dataSource: 'Mock data for development',
    );
  }
}
