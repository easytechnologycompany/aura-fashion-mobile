import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CartItemEntity>>> getItems() async {
    try {
      return Right(await localDataSource.getItems());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> addItem(CartItemEntity item) async {
    try {
      return Right(await localDataSource.addItem(CartItemModel.fromEntity(item)));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> updateQuantity(
    String productId,
    String? variantLabel,
    int quantity,
  ) async {
    try {
      return Right(
        await localDataSource.updateQuantity(productId, variantLabel, quantity),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> removeItem(
    String productId,
    String? variantLabel,
  ) async {
    try {
      return Right(await localDataSource.removeItem(productId, variantLabel));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> clear() async {
    await localDataSource.clear();
    return const Right(null);
  }
}
