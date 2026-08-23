import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';

class OrderLineInput {
  final String productId;
  final int quantity;

  const OrderLineInput({required this.productId, required this.quantity});
}

abstract class OrderRepository {
  Future<Either<Failure, OrderEntity>> createOrder({
    required List<OrderLineInput> items,
    required String shippingAddress,
    String? paymentMethod,
  });

  Future<Either<Failure, OrderEntity>> getOrder(String id);

  Future<Either<Failure, List<OrderEntity>>> listOrders({
    int offset = 0,
    int limit = 20,
  });
}
