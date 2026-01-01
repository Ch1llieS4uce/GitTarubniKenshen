import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/affiliate_product.dart';

/// Live pricing update event
class PriceUpdateEvent {
  const PriceUpdateEvent({
    required this.tick,
    required this.products,
    required this.timestamp,
  });

  final int tick;
  final List<AffiliateProduct> products;
  final DateTime timestamp;

  factory PriceUpdateEvent.fromJson(Map<String, dynamic> json) {
    final productsData = json['products'] as List<dynamic>? ?? [];
    return PriceUpdateEvent(
      tick: json['tick'] as int? ?? 0,
      products: productsData
          .map((e) => AffiliateProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Live pricing service for real-time price updates
class LivePricingService {
  LivePricingService(this._dio);

  final Dio _dio;
  
  StreamController<PriceUpdateEvent>? _streamController;
  Timer? _pollTimer;
  int _lastTick = 0;
  bool _isConnected = false;
  bool _enabled = true;

  /// Whether live pricing is enabled
  bool get enabled => _enabled;
  
  /// Whether currently connected to stream
  bool get isConnected => _isConnected;

  /// Stream of price updates
  Stream<PriceUpdateEvent> get updates {
    _streamController ??= StreamController<PriceUpdateEvent>.broadcast(
      onListen: _startPolling,
      onCancel: _stopPolling,
    );
    return _streamController!.stream;
  }

  /// Toggle live pricing on/off
  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    if (enabled) {
      _startPolling();
    } else {
      _stopPolling();
    }
    
    // Persist preference to backend
    try {
      await _dio.post(
        '${AppConfig.baseUrl}/api/live-pricing/toggle',
        data: {'enabled': enabled},
      );
    } catch (e) {
      debugPrint('Failed to persist live pricing preference: $e');
    }
  }

  /// Get pricing explanation for a product
  Future<Map<String, dynamic>?> explainPricing(String platform, String productId) async {
    if (AppConfig.useMockData) {
      return _getMockExplanation(platform, productId);
    }

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/api/live-pricing/explain/$platform/$productId',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Failed to get pricing explanation: $e');
    }

    return _getMockExplanation(platform, productId);
  }

  /// Start polling for updates (fallback for SSE)
  void _startPolling() {
    if (_pollTimer != null || !_enabled) return;
    
    _isConnected = true;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
    
    // Initial poll
    _poll();
  }

  /// Stop polling
  void _stopPolling() {
    _isConnected = false;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Poll for updates
  Future<void> _poll() async {
    if (!_enabled) return;

    try {
      if (AppConfig.useMockData) {
        _emitMockUpdate();
        return;
      }

      final response = await _dio.get(
        '${AppConfig.baseUrl}/api/live-pricing/poll',
        queryParameters: {
          'since_tick': _lastTick,
          'limit': 20,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final hasUpdates = data['has_updates'] as bool? ?? false;
        
        if (hasUpdates) {
          final tick = data['tick'] as int? ?? 0;
          _lastTick = tick;
          
          final event = PriceUpdateEvent.fromJson(data);
          _streamController?.add(event);
        }
      }
    } catch (e) {
      debugPrint('Live pricing poll failed: $e');
      // Emit mock update as fallback
      _emitMockUpdate();
    }
  }

  /// Emit mock update for development
  void _emitMockUpdate() {
    _lastTick++;
    
    final products = <AffiliateProduct>[];
    final platforms = ['lazada', 'shopee', 'tiktok'];
    final updateCount = 3 + (_lastTick % 5);

    for (var i = 0; i < updateCount; i++) {
      final platform = platforms[i % 3];
      final basePrice = 100.0 + ((_lastTick * 17 + i * 23) % 5000);
      final priceChange = ((_lastTick * 7 + i * 11) % 100 - 50) / 100;
      final newPrice = basePrice * (1 + priceChange * 0.015);
      final competitorAvg = newPrice * (1 + (i % 10) / 100);
      final demandFactor = 0.3 + ((_lastTick + i) % 60) / 100;
      
      // Calculate AI recommendation
      const alpha = 0.65;
      const beta = 0.35;
      const gamma = 0.05;
      final minPrice = newPrice * 0.7;
      final recommended = (alpha * competitorAvg) + (beta * minPrice) + (gamma * competitorAvg * demandFactor);
      final ceiling = competitorAvg * 1.07;
      final clampedRecommended = recommended.clamp(minPrice, ceiling);

      products.add(AffiliateProduct(
        platform: platform,
        id: '$platform-${1000 + i}',
        title: 'Dynamic Product ${i + 1}',
        url: 'https://$platform.com/product/${1000 + i}',
        affiliateUrl: 'https://$platform.com/aff/${1000 + i}',
        price: newPrice,
        originalPrice: newPrice * 1.2,
        discount: 20,
        rating: 4.0 + (i % 10) / 10,
        reviewCount: 100 + i * 50,
        sellerRating: 4.5,
        image: 'https://via.placeholder.com/300x300/1a1a2e/FFFFFF.png?text=Product+${i + 1}',
        recommendedPrice: clampedRecommended,
        confidence: 0.7 + (i % 20) / 100,
        demandFactor: demandFactor,
        competitorAvg: competitorAvg,
        modelVersion: 'mock-formula-v2',
        pricingUpdatedAt: DateTime.now(),
      ));
    }

    _streamController?.add(PriceUpdateEvent(
      tick: _lastTick,
      products: products,
      timestamp: DateTime.now(),
    ));
  }

  /// Get mock explanation
  Map<String, dynamic> _getMockExplanation(String platform, String productId) {
    const competitorAvg = 599.99;
    const minPrice = 419.99;
    const demandFactor = 0.65;
    const alpha = 0.65;
    const beta = 0.35;
    const gamma = 0.05;

    const alphaComponent = alpha * competitorAvg;
    const betaComponent = beta * minPrice;
    const gammaComponent = gamma * competitorAvg * demandFactor;
    const candidateRaw = alphaComponent + betaComponent + gammaComponent;
    const ceiling = competitorAvg * 1.07;
    final recommended = candidateRaw.clamp(minPrice, ceiling);

    return {
      'success': true,
      'product': {
        'id': productId,
        'platform': platform,
        'price': 549.99,
        'original_price': 699.99,
      },
      'explanation': {
        'algorithm': 'Weighted Price Optimization v2',
        'formula': 'P = α×Pc + β×Pmin + γ×Pc×Df',
        'inputs': {
          'competitor_avg': {
            'value': competitorAvg,
            'description': 'Average price across competing platforms',
            'weight': 'α = $alpha',
          },
          'min_price': {
            'value': minPrice,
            'description': 'Cost + 30% minimum margin',
            'weight': 'β = $beta',
          },
          'demand_factor': {
            'value': demandFactor,
            'description': 'Market demand indicator (0-1)',
            'weight': 'γ = $gamma',
          },
        },
        'components': {
          'alpha_contribution': {
            'value': alphaComponent,
            'formula': 'α × Pc = $alpha × $competitorAvg',
          },
          'beta_contribution': {
            'value': betaComponent,
            'formula': 'β × Pmin = $beta × $minPrice',
          },
          'gamma_contribution': {
            'value': gammaComponent,
            'formula': 'γ × Pc × Df = $gamma × $competitorAvg × $demandFactor',
          },
        },
        'calculation': {
          'candidate_raw': candidateRaw,
          'ceiling': ceiling,
          'min_price': minPrice,
          'clamp_applied': candidateRaw != recommended,
          'final_recommended': recommended,
        },
        'explanation': 'Moderate demand ($demandFactor) with competitive positioning. '
            'Price is ${((1 - recommended / competitorAvg) * 100).toStringAsFixed(1)}% below '
            'competitor average for market advantage.',
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose resources
  void dispose() {
    _stopPolling();
    _streamController?.close();
    _streamController = null;
  }
}
