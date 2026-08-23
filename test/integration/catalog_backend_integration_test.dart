// Exercises the real CategoryRemoteDataSourceImpl and
// ProductRemoteDataSourceImpl over HTTP against a running
// aura-fashion-backend instance. Not run as part of the default
// `flutter test` suite — start the backend first, then run explicitly:
//
//   flutter test test/integration/catalog_backend_integration_test.dart \
//     --dart-define=API_BASE_URL=http://localhost:8080/api/v1
//
// Skips automatically if the backend isn't reachable.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura_fashion_mobile/core/constants/api_constants.dart';
import 'package:aura_fashion_mobile/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:aura_fashion_mobile/features/products/data/datasources/product_remote_data_source.dart';

void main() {
  late Dio dio;
  late CategoryRemoteDataSourceImpl categoryDataSource;
  late ProductRemoteDataSourceImpl productDataSource;
  var backendAvailable = false;

  setUpAll(() async {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    categoryDataSource = CategoryRemoteDataSourceImpl(dio);
    productDataSource = ProductRemoteDataSourceImpl(dio);
    try {
      final response = await Dio().get(
        '${ApiConstants.baseUrl.replaceFirst('/api/v1', '')}/health',
      );
      backendAvailable = response.statusCode == 200;
    } catch (_) {
      backendAvailable = false;
    }
  });

  test('categories load from the live backend', () async {
    if (!backendAvailable) {
      markTestSkipped('backend not reachable at ${ApiConstants.baseUrl}');
      return;
    }

    final categories = await categoryDataSource.getCategories();

    expect(categories, isNotEmpty);
    for (final category in categories) {
      expect(category.id, isNotEmpty);
      expect(category.name, isNotEmpty);
    }
  });

  test('products load and can be filtered by category', () async {
    if (!backendAvailable) {
      markTestSkipped('backend not reachable at ${ApiConstants.baseUrl}');
      return;
    }

    final categories = await categoryDataSource.getCategories();
    expect(categories, isNotEmpty);
    final targetCategory = categories.first;

    final allProducts = await productDataSource.getProducts(offset: 0, limit: 20);
    expect(allProducts.products, isNotEmpty);
    expect(allProducts.total, greaterThanOrEqualTo(allProducts.products.length));

    final filtered = await productDataSource.getProducts(
      offset: 0,
      limit: 20,
      categoryId: targetCategory.id,
    );
    expect(filtered.products, isNotEmpty);
    for (final product in filtered.products) {
      expect(product.categoryId, targetCategory.id);
    }
  });
}
