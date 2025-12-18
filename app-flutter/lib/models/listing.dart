import 'product.dart';

class Listing {
  const Listing({
    required this.id,
    required this.platformProductId,
    required this.price,
    required this.stock,
    required this.status,
    required this.platform,
    required this.accountName,
    required this.product,
  });

  factory Listing.fromJson(Map<String, dynamic> json) => Listing(
        id: (json['id'] as num).toInt(),
        platformProductId: json['platform_product_id'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? 'active',
        platform: (json['platform_account'] as Map<String, dynamic>?)?['platform'] as String? ?? '',
        accountName:
            (json['platform_account'] as Map<String, dynamic>?)?['account_name'] as String? ?? '',
        product: Product.fromJson((json['product'] as Map<String, dynamic>?) ?? const {}),
      );

  final int id;
  final String platformProductId;
  final double price;
  final int stock;
  final String status;
  final String platform;
  final String accountName;
  final Product product;
}

