import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fixed_product.dart';
import '../services/product_service.dart';

/// Provider for the ProductService
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

/// State for lowest price recommendations
class LowestPriceState {
  final List<LowestPriceRecommendation> recommendations;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int offset;

  const LowestPriceState({
    this.recommendations = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.offset = 0,
  });

  LowestPriceState copyWith({
    List<LowestPriceRecommendation>? recommendations,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? offset,
  }) {
    return LowestPriceState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }
}

/// Notifier for lowest price recommendations
class LowestPriceNotifier extends StateNotifier<LowestPriceState> {
  final ProductService _service;
  static const int _pageSize = 20;

  LowestPriceNotifier(this._service) : super(const LowestPriceState());

  /// Fetch initial recommendations
  Future<void> fetchRecommendations({String? category}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final recommendations = await _service.getLowestPriceRecommendations(
        limit: _pageSize,
        offset: 0,
        category: category,
      );

      state = state.copyWith(
        recommendations: recommendations,
        isLoading: false,
        hasMore: recommendations.length >= _pageSize,
        offset: recommendations.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more recommendations
  Future<void> loadMore({String? category}) async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final newRecommendations = await _service.getLowestPriceRecommendations(
        limit: _pageSize,
        offset: state.offset,
        category: category,
      );

      state = state.copyWith(
        recommendations: [...state.recommendations, ...newRecommendations],
        isLoading: false,
        hasMore: newRecommendations.length >= _pageSize,
        offset: state.offset + newRecommendations.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh recommendations
  Future<void> refresh({String? category}) async {
    state = const LowestPriceState();
    await fetchRecommendations(category: category);
  }
}

/// Provider for lowest price recommendations
final lowestPriceNotifierProvider =
    StateNotifierProvider<LowestPriceNotifier, LowestPriceState>((ref) {
  final service = ref.watch(productServiceProvider);
  return LowestPriceNotifier(service);
});

/// Provider for a single product by ID
final productByIdProvider = FutureProvider.family<FixedProduct?, String>((ref, id) async {
  final service = ref.watch(productServiceProvider);
  return service.getProduct(id);
});

/// State for products list
class ProductsState {
  final List<FixedProduct> products;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int offset;
  final String? platform;
  final String? category;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.offset = 0,
    this.platform,
    this.category,
  });

  ProductsState copyWith({
    List<FixedProduct>? products,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? offset,
    String? platform,
    String? category,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      platform: platform ?? this.platform,
      category: category ?? this.category,
    );
  }
}

/// Notifier for products list
class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductService _service;
  static const int _pageSize = 50;

  ProductsNotifier(this._service) : super(const ProductsState());

  /// Fetch products with optional filters
  Future<void> fetchProducts({String? platform, String? category}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      platform: platform,
      category: category,
    );

    try {
      final products = await _service.getProducts(
        limit: _pageSize,
        offset: 0,
        platform: platform,
        category: category,
      );

      state = state.copyWith(
        products: products,
        isLoading: false,
        hasMore: products.length >= _pageSize,
        offset: products.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more products
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final newProducts = await _service.getProducts(
        limit: _pageSize,
        offset: state.offset,
        platform: state.platform,
        category: state.category,
      );

      state = state.copyWith(
        products: [...state.products, ...newProducts],
        isLoading: false,
        hasMore: newProducts.length >= _pageSize,
        offset: state.offset + newProducts.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh products
  Future<void> refresh() async {
    final platform = state.platform;
    final category = state.category;
    state = const ProductsState();
    await fetchProducts(platform: platform, category: category);
  }
}

/// Provider for products list
final productsNotifierProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final service = ref.watch(productServiceProvider);
  return ProductsNotifier(service);
});
