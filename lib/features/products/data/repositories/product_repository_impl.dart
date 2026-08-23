import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedProducts>> getProducts({
    int offset = 0,
    int limit = 20,
    String? categoryId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final page = await remoteDataSource.getProducts(
        offset: offset,
        limit: limit,
        categoryId: categoryId,
      );
      return Right(
        PaginatedProducts(products: page.products, total: page.total),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final product = await remoteDataSource.getProductById(id);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
