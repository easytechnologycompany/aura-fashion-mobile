import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItemEntity>>> getItems();

  /// Adds [quantity] of the item; if the product is already in the cart the
  /// quantities are merged (capped at [CartItemEntity.availableStock]).
  Future<Either<Failure, List<CartItemEntity>>> addItem(CartItemEntity item);

  Future<Either<Failure, List<CartItemEntity>>> updateQuantity(
    String productId,
    String? variantLabel,
    int quantity,
  );

  Future<Either<Failure, List<CartItemEntity>>> removeItem(
    String productId,
    String? variantLabel,
  );

  Future<Either<Failure, void>> clear();
}
