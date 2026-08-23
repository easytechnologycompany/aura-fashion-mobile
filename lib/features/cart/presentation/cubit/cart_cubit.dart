import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_cart_item_quantity_usecase.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartItemQuantityUseCase updateCartItemQuantityUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartCubit({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.updateCartItemQuantityUseCase,
    required this.removeFromCartUseCase,
    required this.clearCartUseCase,
  }) : super(const CartState());

  Future<void> loadCart() async {
    emit(state.copyWith(status: CartStatus.loading));
    final result = await getCartUseCase(const NoParams());
    _emitResult(result);
  }

  Future<void> addItem(CartItemEntity item) async {
    final result = await addToCartUseCase(item);
    _emitResult(result);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final result = await updateCartItemQuantityUseCase(
      UpdateCartItemQuantityParams(productId: productId, quantity: quantity),
    );
    _emitResult(result);
  }

  Future<void> removeItem(String productId) async {
    final result = await removeFromCartUseCase(productId);
    _emitResult(result);
  }

  Future<void> clear() async {
    await clearCartUseCase(const NoParams());
    emit(state.copyWith(status: CartStatus.success, items: const []));
  }

  void _emitResult(Either<Failure, List<CartItemEntity>> result) {
    result.fold(
      (failure) => emit(
        state.copyWith(status: CartStatus.failure, errorMessage: failure.message),
      ),
      (items) => emit(state.copyWith(status: CartStatus.success, items: items)),
    );
  }
}
