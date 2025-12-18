import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../providers.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.ref) : super(const AuthState(loading: false));

  final Ref ref;

  AuthService get _auth => ref.read(authServiceProvider);

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final token = await _auth.login(email, password);
      ref.read(apiClientProvider).setToken(token);
      final me = await _auth.me();
      state = AuthState(
        loading: false,
        token: token,
        user: AppUser.fromJson(me),
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final token =
          await _auth.register(name: name, email: email, password: password);
      ref.read(apiClientProvider).setToken(token);
      final me = await _auth.me();
      state = AuthState(
        loading: false,
        token: token,
        user: AppUser.fromJson(me),
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(loading: true);
    try {
      await _auth.logout();
    } catch (_) {
      // ignore; we still clear local session
    } finally {
      ref.read(apiClientProvider).setToken(null);
      state = const AuthState(
        loading: false,
        token: null,
        user: null,
      );
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
