part of 'order_tracking_cubit.dart';

enum OrderTrackingStatus { initial, loading, success, failure }

class OrderTrackingState extends Equatable {
  final OrderTrackingStatus status;
  final OrderEntity? order;
  final String? errorMessage;

  const OrderTrackingState({
    this.status = OrderTrackingStatus.initial,
    this.order,
    this.errorMessage,
  });

  OrderTrackingState copyWith({
    OrderTrackingStatus? status,
    OrderEntity? order,
    String? errorMessage,
  }) {
    return OrderTrackingState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, order, errorMessage];
}
