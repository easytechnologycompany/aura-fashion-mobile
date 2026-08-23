import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartUseCase implements UseCase<List<CartItemEntity>, String> {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartItemEntity>>> call(String productId) {
    return repository.removeItem(productId);
  }
}
