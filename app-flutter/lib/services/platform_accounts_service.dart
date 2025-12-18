import 'package:dio/dio.dart';

import '../models/platform_account.dart';

class PlatformAccountsService {
  PlatformAccountsService(this.dio);

  final Dio dio;

  Future<List<PlatformAccount>> list() async {
    final res = await dio.get('/api/platforms');
    final data = res.data as List<dynamic>? ?? const [];
    return data
        .whereType<Map>()
        .map((e) => PlatformAccount.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<void> connect({
    required String platform,
    required String accountName,
    String? accessToken,
    String? refreshToken,
  }) async {
    await dio.post('/api/platforms/connect', data: {
      'platform': platform,
      'account_name': accountName,
      if (accessToken != null && accessToken.isNotEmpty) 'access_token': accessToken,
      if (refreshToken != null && refreshToken.isNotEmpty) 'refresh_token': refreshToken,
    });
  }

  Future<void> syncNow(int platformAccountId) async {
    await dio.post('/api/sync/$platformAccountId');
  }
}
