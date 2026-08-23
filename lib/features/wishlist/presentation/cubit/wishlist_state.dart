part of 'wishlist_cubit.dart';

enum WishlistStatus { initial, loading, success, failure }

class WishlistState extends Equatable {
  final WishlistStatus status;
  final List<WishlistItemEntity> items;
  final String? errorMessage;

  const WishlistState({
    this.status = WishlistStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  bool contains(String productId) => items.any((i) => i.productId == productId);

  WishlistState copyWith({
    WishlistStatus? status,
    List<WishlistItemEntity>? items,
    String? errorMessage,
  }) {
    return WishlistState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
