import 'package:dio/dio.dart';

import '../models/app_notification.dart';

class NotificationsService {
  NotificationsService(this.dio);

  final Dio dio;

  Future<List<AppNotification>> list({int page = 1}) async {
    final res = await dio.get('/api/notifications', queryParameters: {'page': page});
    final data = (res.data as Map)['data'] as List<dynamic>? ?? const [];
    return data
        .whereType<Map>()
        .map((e) => AppNotification.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<void> markRead(int id) async {
    await dio.post('/api/notifications/$id/read');
  }
}

