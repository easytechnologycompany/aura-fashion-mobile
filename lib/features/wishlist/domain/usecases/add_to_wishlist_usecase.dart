import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wishlist_item_entity.dart';
import '../repositories/wishlist_repository.dart';

class AddToWishlistUseCase
    implements UseCase<List<WishlistItemEntity>, WishlistItemEntity> {
  final WishlistRepository repository;

  AddToWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, List<WishlistItemEntity>>> call(WishlistItemEntity params) {
    return repository.addItem(params);
  }
}
