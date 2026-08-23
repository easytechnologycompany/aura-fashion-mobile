import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase implements UseCase<PaginatedProducts, GetProductsParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedProducts>> call(GetProductsParams params) {
    return repository.getProducts(
      offset: params.offset,
      limit: params.limit,
      categoryId: params.categoryId,
    );
  }
}

class GetProductsParams extends Equatable {
  final int offset;
  final int limit;
  final String? categoryId;

  const GetProductsParams({
    this.offset = 0,
    this.limit = 20,
    this.categoryId,
  });

  @override
  List<Object?> get props => [offset, limit, categoryId];
}
