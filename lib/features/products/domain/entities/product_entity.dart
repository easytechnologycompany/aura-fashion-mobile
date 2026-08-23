import 'package:equatable/equatable.dart';

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
  });

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
      ];
}
