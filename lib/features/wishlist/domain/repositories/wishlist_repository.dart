import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/wishlist_item_entity.dart';

abstract class WishlistRepository {
  Future<Either<Failure, List<WishlistItemEntity>>> getItems();

  /// Adding a product already in the wishlist is a no-op (idempotent).
  Future<Either<Failure, List<WishlistItemEntity>>> addItem(WishlistItemEntity item);

  Future<Either<Failure, List<WishlistItemEntity>>> removeItem(String productId);
}
