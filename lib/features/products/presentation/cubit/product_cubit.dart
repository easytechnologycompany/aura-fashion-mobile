import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase getProductsUseCase;

  ProductCubit({required this.getProductsUseCase}) : super(const ProductState());

  Future<void> fetchProducts({
    String? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    emit(state.copyWith(status: ProductStatus.loading));
    final result = await getProductsUseCase(
      GetProductsParams(
        categoryId: categoryId,
        search: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: ProductStatus.success,
          products: page.products,
          total: page.total,
        ),
      ),
    );
  }
}
