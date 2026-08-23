import 'package:equatable/equatable.dart';

/// A denormalized snapshot of the product at the time it was added — mirrors
/// how the backend snapshots name/price onto `OrderItem` at checkout time.
class CartItemEntity extends Equatable {
  final String productId;
  final String name;
  final String imageUrl;
  final double unitPrice;
  final int quantity;
  final int availableStock;

  /// Display-only label for the selected size/color (e.g. "Size M, Black").
  /// Not sent to the backend — aura-fashion-backend's order API only takes
  /// product_id + quantity today, so variant selection doesn't yet reach
  /// the order record; this exists purely so the cart/checkout UI can show
  /// what the shopper actually picked.
  final String? variantLabel;

  const CartItemEntity({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.availableStock,
    this.variantLabel,
  });

  double get lineTotal => unitPrice * quantity;

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      productId: productId,
      name: name,
      imageUrl: imageUrl,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      availableStock: availableStock,
      variantLabel: variantLabel,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        name,
        imageUrl,
        unitPrice,
        quantity,
        availableStock,
        variantLabel,
      ];
}
