import 'package:dio/dio.dart';

class AdminService {
  AdminService(this.dio);

  final Dio dio;

  Future<Map<String, dynamic>> dashboard() async {
    final res = await dio.get('/api/admin/dashboard');
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> users({int page = 1, int perPage = 20}) async {
    final res = await dio.get('/api/admin/users', queryParameters: {
      'page': page,
      'per_page': perPage,
    });
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<void> updateUserRole(int userId, String role) async {
    await dio.put('/api/admin/users/$userId/role', data: {'role': role});
  }

  Future<Map<String, dynamic>> syncLogs({int page = 1, int perPage = 20}) async {
    final res = await dio.get('/api/admin/sync-logs', queryParameters: {
      'page': page,
      'per_page': perPage,
    });
    return (res.data as Map).cast<String, dynamic>();
  }
}

