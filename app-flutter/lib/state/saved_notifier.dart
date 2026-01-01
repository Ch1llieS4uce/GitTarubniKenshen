import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/affiliate_product.dart';
import 'auth_notifier.dart';

enum SaveResult {
  added,
  removed,
  blockedLoginRequired,
}

class SavedNotifier extends StateNotifier<List<AffiliateProduct>> {
  SavedNotifier(this.ref) : super(const []);

  static const int guestLimit = 3;

  final Ref ref;

  bool _isSame(AffiliateProduct a, AffiliateProduct b) =>
      a.id == b.id && a.platform == b.platform;

  bool isSaved(AffiliateProduct product) =>
      state.any((p) => _isSame(p, product));

  SaveResult toggle(AffiliateProduct product) {
    final existingIndex = state.indexWhere((p) => _isSame(p, product));
    if (existingIndex != -1) {
      state = [
        ...state.sublist(0, existingIndex),
        ...state.sublist(existingIndex + 1),
      ];
      return SaveResult.removed;
    }

    final isAuthenticated = ref.read(authNotifierProvider).isAuthenticated;
    if (!isAuthenticated && state.length >= guestLimit) {
      return SaveResult.blockedLoginRequired;
    }

    state = [product, ...state];
    return SaveResult.added;
  }
}

final savedNotifierProvider =
    StateNotifierProvider<SavedNotifier, List<AffiliateProduct>>(
  SavedNotifier.new,
);

