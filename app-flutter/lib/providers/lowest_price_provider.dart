import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lowest_price_recommendation.dart';
import '../services/lowest_price_service.dart';

/// Provider for the LowestPriceService
final lowestPriceServiceProvider = Provider<LowestPriceService>((ref) {
  return LowestPriceService();
});

/// State for lowest price recommendations
class LowestPriceState {
  final List<LowestPriceRecommendation> recommendations;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const LowestPriceState({
    this.recommendations = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  LowestPriceState copyWith({
    List<LowestPriceRecommendation>? recommendations,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return LowestPriceState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Notifier for managing lowest price recommendations state
class LowestPriceNotifier extends StateNotifier<LowestPriceState> {
  final LowestPriceService _service;

  LowestPriceNotifier(this._service) : super(const LowestPriceState());

  /// Fetch recommendations from API/mock
  Future<void> fetchRecommendations({int limit = 20, String? category}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final recommendations = await _service.getRecommendations(
        limit: limit,
        category: category,
      );

      state = state.copyWith(
        recommendations: recommendations,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load recommendations: $e',
      );
    }
  }

  /// Refresh recommendations
  Future<void> refresh() async {
    await fetchRecommendations();
  }
}

/// Provider for lowest price recommendations state
final lowestPriceProvider =
    StateNotifierProvider<LowestPriceNotifier, LowestPriceState>((ref) {
  final service = ref.watch(lowestPriceServiceProvider);
  return LowestPriceNotifier(service);
});

/// Provider for a single recommendation by group ID
final recommendationByGroupIdProvider =
    Provider.family<LowestPriceRecommendation?, String>((ref, groupId) {
  final state = ref.watch(lowestPriceProvider);
  try {
    return state.recommendations.firstWhere((r) => r.groupId == groupId);
  } catch (_) {
    return null;
  }
});
