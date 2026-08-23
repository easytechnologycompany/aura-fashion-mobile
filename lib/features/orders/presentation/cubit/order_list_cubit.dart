import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/list_orders_usecase.dart';

part 'order_list_state.dart';

class OrderListCubit extends Cubit<OrderListState> {
  final ListOrdersUseCase listOrdersUseCase;

  OrderListCubit({required this.listOrdersUseCase}) : super(const OrderListState());

  Future<void> fetchOrders() async {
    emit(state.copyWith(status: OrderListStatus.loading));
    final result = await listOrdersUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(status: OrderListStatus.failure, errorMessage: failure.message),
      ),
      (orders) => emit(state.copyWith(status: OrderListStatus.success, orders: orders)),
    );
  }
}
