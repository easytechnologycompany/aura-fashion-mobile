import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductByIdUseCase implements UseCase<ProductEntity, GetProductByIdParams> {
  final ProductRepository repository;

  GetProductByIdUseCase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(GetProductByIdParams params) {
    return repository.getProductById(params.id);
  }
}

class GetProductByIdParams extends Equatable {
  final String id;

  const GetProductByIdParams(this.id);

  @override
  List<Object?> get props => [id];
}
