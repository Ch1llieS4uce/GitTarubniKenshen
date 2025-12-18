import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/home_service.dart';
import 'services/search_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final dioProvider = Provider<Dio>((ref) => ref.read(apiClientProvider).dio);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.read(dioProvider)),
);

final homeServiceProvider = Provider<HomeService>(
  (ref) => HomeService(ref.read(dioProvider)),
);

final searchServiceProvider = Provider<SearchService>(
  (ref) => SearchService(ref.read(dioProvider)),
);
