part of 'checkout_cubit.dart';

enum CheckoutStatus { initial, submitting, success, failure }

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final OrderEntity? order;
  final String? errorMessage;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.order,
    this.errorMessage,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    OrderEntity? order,
    String? errorMessage,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, order, errorMessage];
}
