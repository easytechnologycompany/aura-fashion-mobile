import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.productId,
    required super.name,
    required super.imageUrl,
    required super.unitPrice,
    required super.quantity,
    required super.availableStock,
  });

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      productId: entity.productId,
      name: entity.name,
      imageUrl: entity.imageUrl,
      unitPrice: entity.unitPrice,
      quantity: entity.quantity,
      availableStock: entity.availableStock,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      availableStock: json['available_stock'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'image_url': imageUrl,
      'unit_price': unitPrice,
      'quantity': quantity,
      'available_stock': availableStock,
    };
  }
}
