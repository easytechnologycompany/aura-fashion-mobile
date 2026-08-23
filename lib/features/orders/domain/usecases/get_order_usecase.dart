import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrderUseCase implements UseCase<OrderEntity, String> {
  final OrderRepository repository;

  GetOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(String orderId) {
    return repository.getOrder(orderId);
  }
}
