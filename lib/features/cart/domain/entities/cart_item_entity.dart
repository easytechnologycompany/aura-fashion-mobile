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

  const CartItemEntity({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.availableStock,
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
      ];
}
