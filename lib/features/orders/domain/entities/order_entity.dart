import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, productName, unitPrice, quantity];
}

class OrderEntity extends Equatable {
  final String id;
  final String status;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String shippingAddress;
  final List<OrderItemEntity> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderEntity({
    required this.id,
    required this.status,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    this.shippingAddress = '',
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        subtotal,
        shippingFee,
        total,
        shippingAddress,
        items,
        createdAt,
        updatedAt,
      ];
}
