import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartUseCase
    implements UseCase<List<CartItemEntity>, RemoveFromCartParams> {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartItemEntity>>> call(RemoveFromCartParams params) {
    return repository.removeItem(params.productId, params.variantLabel);
  }
}

class RemoveFromCartParams extends Equatable {
  final String productId;
  final String? variantLabel;

  const RemoveFromCartParams({required this.productId, this.variantLabel});

  @override
  List<Object?> get props => [productId, variantLabel];
}
