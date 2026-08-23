import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase implements UseCase<List<CartItemEntity>, CartItemEntity> {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartItemEntity>>> call(CartItemEntity params) {
    return repository.addItem(params);
  }
}
