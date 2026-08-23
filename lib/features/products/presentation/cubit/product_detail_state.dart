part of 'product_detail_cubit.dart';

enum ProductDetailStatus { initial, loading, success, failure }

class ProductDetailState extends Equatable {
  final ProductDetailStatus status;
  final ProductEntity? product;
  final String? errorMessage;

  const ProductDetailState({
    this.status = ProductDetailStatus.initial,
    this.product,
    this.errorMessage,
  });

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    ProductEntity? product,
    String? errorMessage,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product ?? this.product,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, product, errorMessage];
}
