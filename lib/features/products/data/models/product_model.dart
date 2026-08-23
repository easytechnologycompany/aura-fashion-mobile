import '../../domain/entities/product_entity.dart';

/// Maps the JSON shape returned by aura-fashion-backend's `entity.Product`.
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.description,
    required super.price,
    super.salePrice,
    required super.sku,
    required super.stock,
    required super.imageUrl,
    required super.categoryId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String? ?? '',
      price: _toDouble(json['price']),
      salePrice: json['sale_price'] != null ? _toDouble(json['sale_price']) : null,
      sku: json['sku'] as String,
      stock: json['stock'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      categoryId: json['category_id'] as String,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }
}
