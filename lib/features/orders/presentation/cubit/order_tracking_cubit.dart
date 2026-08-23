import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_order_usecase.dart';

part 'order_tracking_state.dart';

class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  final GetOrderUseCase getOrderUseCase;

  OrderTrackingCubit({required this.getOrderUseCase}) : super(const OrderTrackingState());

  Future<void> fetchOrder(String orderId) async {
    emit(state.copyWith(status: OrderTrackingStatus.loading));
    final result = await getOrderUseCase(orderId);
    result.fold(
      (failure) => emit(
        state.copyWith(status: OrderTrackingStatus.failure, errorMessage: failure.message),
      ),
      (order) => emit(state.copyWith(status: OrderTrackingStatus.success, order: order)),
    );
  }
}
