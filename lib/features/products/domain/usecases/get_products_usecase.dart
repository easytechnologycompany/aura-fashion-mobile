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
      search: params.search,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
    );
  }
}

class GetProductsParams extends Equatable {
  final int offset;
  final int limit;
  final String? categoryId;
  final String? search;
  final double? minPrice;
  final double? maxPrice;

  const GetProductsParams({
    this.offset = 0,
    this.limit = 20,
    this.categoryId,
    this.search,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [offset, limit, categoryId, search, minPrice, maxPrice];
}
