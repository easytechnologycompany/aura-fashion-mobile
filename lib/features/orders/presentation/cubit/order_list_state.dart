part of 'order_list_cubit.dart';

enum OrderListStatus { initial, loading, success, failure }

class OrderListState extends Equatable {
  final OrderListStatus status;
  final List<OrderEntity> orders;
  final String? errorMessage;

  const OrderListState({
    this.status = OrderListStatus.initial,
    this.orders = const [],
    this.errorMessage,
  });

  OrderListState copyWith({
    OrderListStatus? status,
    List<OrderEntity>? orders,
    String? errorMessage,
  }) {
    return OrderListState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, errorMessage];
}
