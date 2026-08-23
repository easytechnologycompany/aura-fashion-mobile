import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemQuantityUseCase
    implements UseCase<List<CartItemEntity>, UpdateCartItemQuantityParams> {
  final CartRepository repository;

  UpdateCartItemQuantityUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartItemEntity>>> call(
    UpdateCartItemQuantityParams params,
  ) {
    return repository.updateQuantity(params.productId, params.quantity);
  }
}

class UpdateCartItemQuantityParams extends Equatable {
  final String productId;
  final int quantity;

  const UpdateCartItemQuantityParams({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}
