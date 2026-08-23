import '../../domain/entities/product_variant_entity.dart';

/// Maps the JSON shape returned by aura-fashion-backend's `entity.ProductVariant`.
class ProductVariantModel extends ProductVariantEntity {
  const ProductVariantModel({
    required super.id,
    super.size,
    super.color,
    required super.sku,
    required super.stock,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] as String,
      size: json['size'] as String?,
      color: json['color'] as String?,
      sku: json['sku'] as String,
      stock: json['stock'] as int? ?? 0,
    );
  }
}
