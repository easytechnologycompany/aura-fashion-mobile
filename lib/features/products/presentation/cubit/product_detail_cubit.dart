import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';

part 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final GetProductByIdUseCase getProductByIdUseCase;

  ProductDetailCubit({required this.getProductByIdUseCase})
      : super(const ProductDetailState());

  Future<void> fetchProduct(String id) async {
    emit(state.copyWith(status: ProductDetailStatus.loading));
    final result = await getProductByIdUseCase(GetProductByIdParams(id));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProductDetailStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (product) =>
          emit(state.copyWith(status: ProductDetailStatus.success, product: product)),
    );
  }
}
