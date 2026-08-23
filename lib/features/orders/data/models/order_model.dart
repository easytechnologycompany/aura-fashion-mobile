import '../../domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productId,
    required super.productName,
    required super.unitPrice,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String? ?? '',
      unitPrice: _toDouble(json['unit_price']),
      quantity: json['quantity'] as int? ?? 0,
    );
  }
}

/// Maps the JSON shape returned by aura-fashion-backend's `entity.Order`.
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.status,
    required super.subtotal,
    required super.shippingFee,
    required super.total,
    super.shippingAddress,
    super.items,
    super.createdAt,
    super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      status: json['status'] as String,
      subtotal: _toDouble(json['subtotal']),
      shippingFee: _toDouble(json['shipping_fee']),
      total: _toDouble(json['total']),
      shippingAddress: json['shipping_address'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.parse(value.toString());
}
