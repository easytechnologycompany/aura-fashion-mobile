import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/create_order_usecase.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CreateOrderUseCase createOrderUseCase;

  CheckoutCubit({required this.createOrderUseCase}) : super(const CheckoutState());

  Future<void> placeOrder({
    required List<CartItemEntity> cartItems,
    required String shippingAddress,
    String? paymentMethod,
  }) async {
    emit(state.copyWith(status: CheckoutStatus.submitting));

    final result = await createOrderUseCase(
      CreateOrderParams(
        items: cartItems
            .map((i) => OrderLineInput(productId: i.productId, quantity: i.quantity))
            .toList(),
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: CheckoutStatus.failure, errorMessage: failure.message),
      ),
      (order) => emit(state.copyWith(status: CheckoutStatus.success, order: order)),
    );
  }

  void reset() => emit(const CheckoutState());
}
