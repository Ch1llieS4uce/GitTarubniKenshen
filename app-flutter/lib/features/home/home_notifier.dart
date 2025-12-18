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
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(ref.read(homeServiceProvider)),
);
