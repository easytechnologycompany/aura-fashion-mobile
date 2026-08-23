import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wishlist_item_entity.dart';
import '../repositories/wishlist_repository.dart';

class RemoveFromWishlistUseCase
    implements UseCase<List<WishlistItemEntity>, String> {
  final WishlistRepository repository;

  RemoveFromWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, List<WishlistItemEntity>>> call(String productId) {
    return repository.removeItem(productId);
  }
}
