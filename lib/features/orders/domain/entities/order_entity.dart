import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String id;
  final String status;
  final double subtotal;
  final double shippingFee;
  final double total;

  const OrderEntity({
    required this.id,
    required this.status,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
  });

  @override
  List<Object?> get props => [id, status, subtotal, shippingFee, total];
}
