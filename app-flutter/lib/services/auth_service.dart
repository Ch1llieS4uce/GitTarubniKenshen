import 'package:dio/dio.dart';

class AuthService {
  AuthService(this.dio);

  final Dio dio;

  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await dio.post('/api/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    return res.data['token'] as String;
  }

  Future<String> login(String email, String password) async {
    final res = await dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    return res.data['token'] as String;
  }

  Future<Map<String, dynamic>> me() async {
    final res = await dio.get('/api/me');
    return res.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await dio.post('/api/auth/logout');
  }
}
