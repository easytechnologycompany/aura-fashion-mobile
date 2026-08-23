part of 'product_cubit.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductEntity> products;
  final int total;
  final String? errorMessage;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.total = 0,
    this.errorMessage,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<ProductEntity>? products,
    int? total,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      total: total ?? this.total,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, total, errorMessage];
}
