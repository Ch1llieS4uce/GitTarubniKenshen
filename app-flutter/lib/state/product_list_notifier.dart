import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/affiliate_product.dart';
import '../services/affiliate_product_service.dart';
import '../services/api_client.dart';

/// Provider for the AffiliateProductService
final affiliateProductServiceProvider = Provider<AffiliateProductService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AffiliateProductService(apiClient.dio);
});

/// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// State for paginated product listing
class ProductListState {
  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
    this.total = 0,
    this.platform = 'all',
    this.query,
    this.sort = 'relevance',
  });

  final List<AffiliateProduct> products;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final int total;
  final String platform;
  final String? query;
  final String sort;

  ProductListState copyWith({
    List<AffiliateProduct>? products,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    int? total,
    String? platform,
    String? query,
    String? sort,
  }) =>
      ProductListState(
        products: products ?? this.products,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: error,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        total: total ?? this.total,
        platform: platform ?? this.platform,
        query: query ?? this.query,
        sort: sort ?? this.sort,
      );
}

/// Notifier for managing product list state with pagination
class ProductListNotifier extends StateNotifier<ProductListState> {
  ProductListNotifier(this._service) : super(const ProductListState());

  final AffiliateProductService _service;
  static const int _pageSize = 50;

  /// Load initial products (resets pagination)
  Future<void> loadProducts({
    String platform = 'all',
    String? query,
    String sort = 'relevance',
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      products: [],
      currentPage: 0,
      hasMore: true,
      platform: platform,
      query: query,
      sort: sort,
    );

    try {
      final response = await _service.fetchProducts(
        platform: platform,
        query: query,
        page: 1,
        limit: _pageSize,
        sort: sort,
      );

      state = state.copyWith(
        products: response.products,
        isLoading: false,
        currentPage: 1,
        hasMore: response.hasMore,
        total: response.total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _formatError(e),
      );
    }
  }

  /// Load more products (next page)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _service.fetchProducts(
        platform: state.platform,
        query: state.query,
        page: nextPage,
        limit: _pageSize,
        sort: state.sort,
      );

      state = state.copyWith(
        products: [...state.products, ...response.products],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: response.hasMore,
        total: response.total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: _formatError(e),
      );
    }
  }

  /// Refresh products (reload current filters)
  Future<void> refresh() async {
    await loadProducts(
      platform: state.platform,
      query: state.query,
      sort: state.sort,
    );
  }

  /// Update platform filter
  Future<void> setPlatform(String platform) async {
    if (platform == state.platform) {
      return;
    }
    await loadProducts(
      platform: platform,
      query: state.query,
      sort: state.sort,
    );
  }

  /// Update sort order
  Future<void> setSort(String sort) async {
    if (sort == state.sort) {
      return;
    }
    await loadProducts(
      platform: state.platform,
      query: state.query,
      sort: sort,
    );
  }

  /// Search with query
  Future<void> search(String? query) async {
    await loadProducts(
      platform: state.platform,
      query: query,
      sort: state.sort,
    );
  }

  String _formatError(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.contains('SocketException') ||
          message.contains('Connection refused')) {
        return 'Unable to connect to server. Please check your connection.';
      }
      if (message.contains('timeout')) {
        return 'Request timed out. Please try again.';
      }
    }
    return 'Failed to load products. Please try again.';
  }
}

/// Provider for product list notifier
final productListNotifierProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final service = ref.watch(affiliateProductServiceProvider);
  return ProductListNotifier(service);
});

/// Provider for explore products (guest mode)
final exploreProductsProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final service = ref.watch(affiliateProductServiceProvider);
  return ProductListNotifier(service);
});
