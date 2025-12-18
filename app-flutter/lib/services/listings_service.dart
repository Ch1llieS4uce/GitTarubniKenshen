import 'package:dio/dio.dart';

import '../models/listing.dart';

class ListingsService {
  ListingsService(this.dio);

  final Dio dio;

  Future<List<Listing>> list({int page = 1, int perPage = 20}) async {
    final res = await dio.get('/api/listings', queryParameters: {
      'page': page,
      'per_page': perPage,
    });

    final data = (res.data as Map)['data'] as List<dynamic>? ?? const [];
    return data
        .whereType<Map>()
        .map((e) => Listing.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<Listing> update({
    required int id,
    double? price,
    int? stock,
    String? status,
  }) async {
    final res = await dio.put('/api/listings/$id', data: {
      if (price != null) 'price': price,
      if (stock != null) 'stock': stock,
      if (status != null) 'status': status,
    });
    return Listing.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<Map<String, dynamic>> recommendation(int listingId) async {
    final res = await dio.get('/api/listings/$listingId/recommendation');
    return (res.data as Map).cast<String, dynamic>();
  }
}

