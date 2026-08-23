import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_local_data_source.dart';
import '../models/wishlist_item_model.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistLocalDataSource localDataSource;

  WishlistRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<WishlistItemEntity>>> getItems() async {
    try {
      return Right(await localDataSource.getItems());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<WishlistItemEntity>>> addItem(
    WishlistItemEntity item,
  ) async {
    try {
      return Right(
        await localDataSource.addItem(WishlistItemModel.fromEntity(item)),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<WishlistItemEntity>>> removeItem(
    String productId,
  ) async {
    try {
      return Right(await localDataSource.removeItem(productId));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
