class Product {
  const Product({
    required this.id,
    required this.title,
    required this.sku,
    required this.description,
    required this.mainImage,
    required this.costPrice,
    required this.desiredMargin,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        sku: json['sku'] as String? ?? '',
        description: json['description'] as String? ?? '',
        mainImage: json['main_image'] as String?,
        costPrice: (json['cost_price'] as num?)?.toDouble() ?? 0,
        desiredMargin: (json['desired_margin'] as num?)?.toDouble() ?? 0,
      );

  final int id;
  final String title;
  final String sku;
  final String description;
  final String? mainImage;
  final double costPrice;
  final double desiredMargin;
}

