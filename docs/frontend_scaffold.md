Frontend integration notes (Flutter)
====================================

API endpoints (stable, mock data):
- GET `/api/search?platform=shopee|lazada|tiktok&query=...&page=1&page_size=20`
  - Returns `data[]` items with: `platform`, `platform_product_id`, `title`, `price`, `original_price`, `discount`, `rating`, `review_count`, `seller_rating`, `image`, `url`, `affiliate_url`, `ai_recommendation { recommended_price, confidence, source }`, `data_source`.
- GET `/api/click/{platform}?url=...&platform_product_id=...`
  - Redirects to the affiliate URL and logs the click.

CORS
- Configured in `config/cors.php`; set `CORS_ALLOWED_ORIGINS` in `.env` to your Flutter web origin if applicable.

Dart model
```dart
class AffiliateProduct {
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
  final double? recommendedPrice;
  final double? confidence;
  final String dataSource;

  AffiliateProduct({
    required this.platform,
    required this.id,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.rating,
    required this.reviewCount,
    required this.sellerRating,
    required this.image,
    required this.url,
    required this.affiliateUrl,
    required this.recommendedPrice,
    required this.confidence,
    required this.dataSource,
  });

  factory AffiliateProduct.fromJson(Map<String, dynamic> json) {
    final ai = json['ai_recommendation'] as Map<String, dynamic>?;
    return AffiliateProduct(
      platform: json['platform'],
      id: json['platform_product_id'],
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int?,
      sellerRating: (json['seller_rating'] as num?)?.toDouble(),
      image: json['image'] as String?,
      url: json['url'] ?? '',
      affiliateUrl: json['affiliate_url'] ?? '',
      recommendedPrice: (ai?['recommended_price'] as num?)?.toDouble(),
      confidence: (ai?['confidence'] as num?)?.toDouble(),
      dataSource: json['data_source'] ?? '',
    );
  }
}
```

Dio service
```dart
import 'package:dio/dio.dart';

class SearchApi {
  final Dio _dio;
  SearchApi(this._dio);

  Future<List<AffiliateProduct>> search({
    required String platform,
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await _dio.get('/api/search', queryParameters: {
      'platform': platform,
      'query': query,
      'page': page,
      'page_size': pageSize,
    });
    final data = res.data['data'] as List;
    return data.map((e) => AffiliateProduct.fromJson(e)).toList();
  }
}
```

Riverpod example
```dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'https://your-api-host'));
  return dio;
});

final searchApiProvider = Provider<SearchApi>((ref) {
  return SearchApi(ref.read(dioProvider));
});

class SearchState {
  final bool loading;
  final List<AffiliateProduct> items;
  final String? error;
  final int page;
  final bool endReached;
  SearchState({this.loading=false, this.items=const [], this.error, this.page=1, this.endReached=false});

  SearchState copyWith({bool? loading, List<AffiliateProduct>? items, String? error, int? page, bool? endReached}) {
    return SearchState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      error: error,
      page: page ?? this.page,
      endReached: endReached ?? this.endReached,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchApi api;
  String _platform = 'shopee';
  String _query = '';
  SearchNotifier(this.api): super(SearchState());

  Future<void> search(String platform, String query) async {
    _platform = platform; _query = query;
    state = state.copyWith(loading: true, error: null, page: 1, endReached: false);
    try {
      final items = await api.search(platform: platform, query: query, page: 1);
      state = state.copyWith(loading: false, items: items, page: 1, endReached: items.isEmpty);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.endReached || state.loading) return;
    final nextPage = state.page + 1;
    state = state.copyWith(loading: true);
    try {
      final items = await api.search(platform: _platform, query: _query, page: nextPage);
      state = state.copyWith(
        loading: false,
        items: [...state.items, ...items],
        page: nextPage,
        endReached: items.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final searchNotifierProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.read(searchApiProvider));
});
```

UI tips
- Platform selector + search bar; debounce input before calling the API.
- Show badges: platform, discount %, rating stars; show `data_source` attribution text.
- Clearly label AI vs platform data (e.g., “AI Recommended ₱X”).
- Use infinite scroll calling `loadMore()` until `endReached`.
- On “Buy”/“View” tap, call `/api/click/{platform}` (or open `affiliateUrl` during mock phase).

Error/limits
- Handle 429/500 with retry UI; throttle client-side requests.
- Show empty state when no items are returned.

Swap to real APIs
- The backend contracts stay the same; once real platform keys are available, replace mock clients server-side without changing the Flutter code.
