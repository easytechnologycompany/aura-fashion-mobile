import 'package:equatable/equatable.dart';

import 'product_variant_entity.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final double? salePrice;
  final String sku;
  final int stock;
  final String imageUrl;
  final String categoryId;
  final List<ProductVariantEntity> variants;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.salePrice,
    required this.sku,
    required this.stock,
    required this.imageUrl,
    required this.categoryId,
    this.variants = const [],
  });

  /// Distinct sizes across variants, in the order they first appear.
  List<String> get availableSizes =>
      variants.map((v) => v.size).whereType<String>().toSet().toList();

  /// Distinct colors across variants, in the order they first appear.
  List<String> get availableColors =>
      variants.map((v) => v.color).whereType<String>().toSet().toList();

  double get effectivePrice => salePrice ?? price;
  bool get isOnSale => salePrice != null && salePrice! < price;
  bool get inStock => stock > 0;

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        price,
        salePrice,
        sku,
        stock,
        imageUrl,
        categoryId,
        variants,
      ];
}
