import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/usecases/add_to_wishlist_usecase.dart';
import '../../domain/usecases/get_wishlist_usecase.dart';
import '../../domain/usecases/remove_from_wishlist_usecase.dart';

part 'wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final GetWishlistUseCase getWishlistUseCase;
  final AddToWishlistUseCase addToWishlistUseCase;
  final RemoveFromWishlistUseCase removeFromWishlistUseCase;

  WishlistCubit({
    required this.getWishlistUseCase,
    required this.addToWishlistUseCase,
    required this.removeFromWishlistUseCase,
  }) : super(const WishlistState());

  Future<void> loadWishlist() async {
    emit(state.copyWith(status: WishlistStatus.loading));
    final result = await getWishlistUseCase(const NoParams());
    _emitResult(result);
  }

  Future<void> addItem(WishlistItemEntity item) async {
    final result = await addToWishlistUseCase(item);
    _emitResult(result);
  }

  Future<void> removeItem(String productId) async {
    final result = await removeFromWishlistUseCase(productId);
    _emitResult(result);
  }

  /// Toggles wishlist membership for the given product — the shape every
  /// heart-icon button in the app actually calls.
  Future<void> toggle(WishlistItemEntity item) {
    return state.contains(item.productId)
        ? removeItem(item.productId)
        : addItem(item);
  }

  void _emitResult(Either<Failure, List<WishlistItemEntity>> result) {
    result.fold(
      (failure) => emit(
        state.copyWith(status: WishlistStatus.failure, errorMessage: failure.message),
      ),
      (items) => emit(state.copyWith(status: WishlistStatus.success, items: items)),
    );
  }
}
