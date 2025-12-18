import '../models/app_user.dart';

class AuthState {
  const AuthState({
    required this.loading,
    this.token,
    this.user,
    this.error,
  });

  final bool loading;
  final String? token;
  final AppUser? user;
  final String? error;

  bool get isAuthenticated => token != null && user != null;

  AuthState copyWith({
    bool? loading,
    String? token,
    AppUser? user,
    String? error,
  }) =>
      AuthState(
        loading: loading ?? this.loading,
        token: token ?? this.token,
        user: user ?? this.user,
        error: error,
      );
}

