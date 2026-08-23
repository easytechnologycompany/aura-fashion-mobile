import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase implements UseCase<OrderEntity, CreateOrderParams> {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) {
    return repository.createOrder(
      items: params.items,
      shippingAddress: params.shippingAddress,
      paymentMethod: params.paymentMethod,
    );
  }
}

class CreateOrderParams extends Equatable {
  final List<OrderLineInput> items;
  final String shippingAddress;
  final String? paymentMethod;

  const CreateOrderParams({
    required this.items,
    required this.shippingAddress,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [items, shippingAddress, paymentMethod];
}
