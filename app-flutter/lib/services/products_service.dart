import 'package:dio/dio.dart';

import '../models/product.dart';

class ProductsService {
  ProductsService(this.dio);

  final Dio dio;

  Future<List<Product>> list({int page = 1, int perPage = 20}) async {
    final res = await dio.get('/api/products', queryParameters: {
      'page': page,
      'per_page': perPage,
    });

    final data = (res.data as Map)['data'] as List<dynamic>? ?? const [];
    return data
        .whereType<Map>()
        .map((e) => Product.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<Product> create({
    required String title,
    required double costPrice,
    required double desiredMargin,
    String? sku,
    String? description,
    String? mainImage,
  }) async {
    final res = await dio.post('/api/products', data: {
      'title': title,
      'cost_price': costPrice,
      'desired_margin': desiredMargin,
      if (sku != null && sku.isNotEmpty) 'sku': sku,
      if (description != null && description.isNotEmpty) 'description': description,
      if (mainImage != null && mainImage.isNotEmpty) 'main_image': mainImage,
    });
    return Product.fromJson((res.data as Map).cast<String, dynamic>());
  }
}

