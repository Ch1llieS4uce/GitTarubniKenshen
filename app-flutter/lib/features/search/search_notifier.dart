import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/affiliate_product.dart';
import '../../providers.dart';
import '../../services/search_service.dart';

class SearchState {
  const SearchState({
    this.loading = false,
    this.items = const [],
    this.error,
    this.page = 1,
    this.endReached = false,
    this.platform = 'shopee',
    this.query = '',
  });

  final bool loading;
  final List<AffiliateProduct> items;
  final String? error;
  final int page;
  final bool endReached;
  final String platform;
  final String query;

  SearchState copyWith({
    bool? loading,
    List<AffiliateProduct>? items,
    String? error,
    int? page,
    bool? endReached,
    String? platform,
    String? query,
  }) =>
      SearchState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
        error: error,
        page: page ?? this.page,
        endReached: endReached ?? this.endReached,
        platform: platform ?? this.platform,
        query: query ?? this.query,
      );
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this.service) : super(const SearchState());

  final SearchService service;

  Future<void> search(String platform, String query) async {
    state = state.copyWith(
      loading: true,
      error: null,
      page: 1,
      endReached: false,
      platform: platform,
      query: query,
    );
    try {
      final res = await service.search(
        platform: platform,
        query: query,
        page: 1,
      );
      state = state.copyWith(
        loading: false,
        items: res,
        page: 1,
        endReached: res.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.endReached || state.loading) {
      return;
    }
    final nextPage = state.page + 1;
    state = state.copyWith(loading: true);
    try {
      final res = await service.search(
        platform: state.platform,
        query: state.query,
        page: nextPage,
      );
      state = state.copyWith(
        loading: false,
        items: [...state.items, ...res],
        page: nextPage,
        endReached: res.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(ref.read(searchServiceProvider)),
);
