import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/affiliate_product.dart';
import '../services/live_pricing_service.dart';

/// Live pricing state
class LivePricingState {
  const LivePricingState({
    this.enabled = true,
    this.isConnected = false,
    this.lastTick = 0,
    this.lastUpdatedAt,
    this.updatedProducts = const {},
    this.error,
  });

  final bool enabled;
  final bool isConnected;
  final int lastTick;
  final DateTime? lastUpdatedAt;
  final Map<String, AffiliateProduct> updatedProducts; // key = "platform:id"
  final String? error;

  LivePricingState copyWith({
    bool? enabled,
    bool? isConnected,
    int? lastTick,
    DateTime? lastUpdatedAt,
    Map<String, AffiliateProduct>? updatedProducts,
    String? error,
  }) {
    return LivePricingState(
      enabled: enabled ?? this.enabled,
      isConnected: isConnected ?? this.isConnected,
      lastTick: lastTick ?? this.lastTick,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      updatedProducts: updatedProducts ?? this.updatedProducts,
      error: error,
    );
  }

  /// Get updated product by platform and ID
  AffiliateProduct? getUpdatedProduct(String platform, String id) {
    return updatedProducts['$platform:$id'];
  }

  /// Merge product with live updates if available
  AffiliateProduct mergeWithLiveData(AffiliateProduct product) {
    final updated = getUpdatedProduct(product.platform, product.id);
    if (updated == null) return product;
    
    return product.copyWithLivePricing(
      recommendedPrice: updated.recommendedPrice,
      confidence: updated.confidence,
      demandFactor: updated.demandFactor,
      competitorAvg: updated.competitorAvg,
      modelVersion: updated.modelVersion,
      pricingUpdatedAt: updated.pricingUpdatedAt,
      priceDirection: updated.priceDirection,
      price: updated.price,
    );
  }
}

/// Live pricing notifier
class LivePricingNotifier extends StateNotifier<LivePricingState> {
  LivePricingNotifier(this._service) : super(const LivePricingState()) {
    _init();
  }

  final LivePricingService _service;
  StreamSubscription<PriceUpdateEvent>? _subscription;
  
  void _init() {
    _subscription = _service.updates.listen(
      _onPriceUpdate,
      onError: _onError,
    );
  }

  void _onPriceUpdate(PriceUpdateEvent event) {
    final updatedProducts = Map<String, AffiliateProduct>.from(
      state.updatedProducts,
    );
    
    for (final product in event.products) {
      updatedProducts['${product.platform}:${product.id}'] = product;
    }
    
    state = state.copyWith(
      isConnected: true,
      lastTick: event.tick,
      lastUpdatedAt: event.timestamp,
      updatedProducts: updatedProducts,
      error: null,
    );
  }

  void _onError(Object error) {
    state = state.copyWith(
      error: 'Live pricing temporarily unavailable',
    );
  }

  /// Toggle live pricing on/off
  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await _service.setEnabled(enabled);
  }

  /// Get pricing explanation for a product
  Future<Map<String, dynamic>?> explainPricing(
    String platform, 
    String productId,
  ) async {
    return _service.explainPricing(platform, productId);
  }

  /// Clear all cached updates
  void clearCache() {
    state = state.copyWith(
      updatedProducts: {},
      lastTick: 0,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}

/// Dio provider for HTTP client
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));
  
  return dio;
});

/// Live pricing service provider
final livePricingServiceProvider = Provider<LivePricingService>((ref) {
  final dio = ref.watch(dioProvider);
  return LivePricingService(dio);
});

/// Live pricing state provider
final livePricingProvider = 
    StateNotifierProvider<LivePricingNotifier, LivePricingState>((ref) {
  final service = ref.watch(livePricingServiceProvider);
  return LivePricingNotifier(service);
});

/// Helper provider to get a merged product with live data
final mergedProductProvider = Provider.family<AffiliateProduct, AffiliateProduct>(
  (ref, product) {
    final livePricing = ref.watch(livePricingProvider);
    return livePricing.mergeWithLiveData(product);
  },
);

/// Provider to check if live pricing is enabled
final livePricingEnabledProvider = Provider<bool>((ref) {
  return ref.watch(livePricingProvider).enabled;
});

/// Provider for last update timestamp
final lastPricingUpdateProvider = Provider<DateTime?>((ref) {
  return ref.watch(livePricingProvider).lastUpdatedAt;
});
