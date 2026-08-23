import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

class ProductsPage {
  final List<ProductModel> products;
  final int total;

  const ProductsPage({required this.products, required this.total});
}

abstract class ProductRemoteDataSource {
  Future<ProductsPage> getProducts({
    required int offset,
    required int limit,
    String? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
  });

  Future<ProductModel> getProductById(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<ProductsPage> getProducts({
    required int offset,
    required int limit,
    String? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.products,
        queryParameters: {
          'offset': offset,
          'limit': limit,
          'category_id': ?categoryId,
          'q': ?search,
          'min_price': ?minPrice,
          'max_price': ?maxPrice,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final items = (data['data'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ProductsPage(products: items, total: data['total'] as int);
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await dio.get(ApiConstants.product(id));
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }
    return e.message ?? 'Unexpected network error';
  }
}
