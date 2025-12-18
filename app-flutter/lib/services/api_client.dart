import 'package:dio/dio.dart';

import '../config/app_config.dart';

class ApiClient {
  ApiClient({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                validateStatus: (status) => status != null && status < 400,
              ),
            ) {
    // Add error interceptor for better error handling
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _handleError(error);
          return handler.next(error);
        },
      ),
    );
  }

  final Dio dio;

  void setToken(String? token) {
    if (token == null) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  void _handleError(DioException error) {
    // Log error details - can be extended to send to analytics service
    _logError('API Error: ${error.type} - ${error.message}');
  }

  static void _logError(String message) {
    // In production, this could be sent to a logging service like Firebase, Sentry, etc.
    // ignore: avoid_print
    print('\x1B[31m$message\x1B[0m'); // Red colored output
  }
}
