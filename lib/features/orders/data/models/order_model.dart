import '../../domain/entities/order_entity.dart';

/// Maps the JSON shape returned by aura-fashion-backend's `entity.Order`.
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.status,
    required super.subtotal,
    required super.shippingFee,
    required super.total,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      status: json['status'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingFee: (json['shipping_fee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}
