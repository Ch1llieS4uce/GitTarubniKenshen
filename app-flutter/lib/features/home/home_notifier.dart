import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../services/home_service.dart';

export '../../services/home_service.dart' show HomeSection;

class HomeState {
  const HomeState({
    this.loading = false,
    this.sections = const [],
    this.error,
  });

  final bool loading;
  final List<HomeSection> sections;
  final String? error;

  HomeState copyWith({
    bool? loading,
    List<HomeSection>? sections,
    String? error,
  }) =>
      HomeState(
        loading: loading ?? this.loading,
        sections: sections ?? this.sections,
        error: error,
      );
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this.service) : super(const HomeState());

  final HomeService service;

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final sections = await service.fetchHome();
      state = state.copyWith(loading: false, sections: sections);
    } catch (e) {
      // Log technical details to console only
      debugPrint('[HomeNotifier] Error loading home: $e');
      // Show user-friendly message
      state = state.copyWith(
        loading: false,
        error: _getUserFriendlyError(e),
      );
    }
  }

  String _getUserFriendlyError(Object error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('connection') ||
        errorStr.contains('socket') ||
        errorStr.contains('xmlhttprequest') ||
        errorStr.contains('network')) {
      return 'Unable to connect. Please check your internet and try again.';
    }
    if (errorStr.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (errorStr.contains('401') || errorStr.contains('403')) {
      return 'Access denied. Please sign in to continue.';
    }
    if (errorStr.contains('404')) {
      return 'Content not available right now.';
    }
    if (errorStr.contains('500') || errorStr.contains('server')) {
      return 'Server is temporarily unavailable. Please try again later.';
    }
    return 'Something went wrong. Please try again.';
  }
}

final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(ref.read(homeServiceProvider)),
);
