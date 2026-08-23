import 'package:equatable/equatable.dart';

/// A denormalized snapshot of the product at the time it was wishlisted —
/// same rationale as CartItemEntity: the display data travels with the
/// item so the wishlist screen doesn't need a fresh product fetch per item.
class WishlistItemEntity extends Equatable {
  final String productId;
  final String name;
  final String imageUrl;
  final double unitPrice;
  final double? salePrice;

  const WishlistItemEntity({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    this.salePrice,
  });

  double get effectivePrice => salePrice ?? unitPrice;
  bool get isOnSale => salePrice != null && salePrice! < unitPrice;

  @override
  List<Object?> get props => [productId, name, imageUrl, unitPrice, salePrice];
}
