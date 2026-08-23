import 'package:equatable/equatable.dart';

class ProductVariantEntity extends Equatable {
  final String id;
  final String? size;
  final String? color;
  final String sku;
  final int stock;

  const ProductVariantEntity({
    required this.id,
    this.size,
    this.color,
    required this.sku,
    required this.stock,
  });

  bool get inStock => stock > 0;

  @override
  List<Object?> get props => [id, size, color, sku, stock];
}
