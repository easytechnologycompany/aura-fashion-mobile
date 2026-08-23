// Exercises the real OrderRemoteDataSourceImpl over HTTP against a running
// aura-fashion-backend instance, proving the cart -> checkout flow's network
// layer actually places an order. Not run as part of the default
// `flutter test` suite — start the backend first, then run explicitly:
//
//   flutter test test/integration/checkout_backend_integration_test.dart \
//     --dart-define=API_BASE_URL=http://localhost:8080/api/v1
//
// Skips automatically if the backend isn't reachable, or if no products
// exist yet to order (run catalog_backend_integration_test.dart's setup,
// or seed at least one product, first).
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura_fashion_mobile/core/constants/api_constants.dart';
import 'package:aura_fashion_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aura_fashion_mobile/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:aura_fashion_mobile/features/orders/domain/repositories/order_repository.dart';
import 'package:aura_fashion_mobile/features/products/data/datasources/product_remote_data_source.dart';

void main() {
  late Dio authDio;
  late Dio orderDio;
  late AuthRemoteDataSourceImpl authDataSource;
  late ProductRemoteDataSourceImpl productDataSource;
  late OrderRemoteDataSourceImpl orderDataSource;
  var backendAvailable = false;
  String? token;

  setUpAll(() async {
    authDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    orderDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    authDataSource = AuthRemoteDataSourceImpl(authDio);
    productDataSource = ProductRemoteDataSourceImpl(Dio(
      BaseOptions(baseUrl: ApiConstants.baseUrl),
    ));
    orderDataSource = OrderRemoteDataSourceImpl(orderDio);

    try {
      final response = await Dio().get(
        '${ApiConstants.baseUrl.replaceFirst('/api/v1', '')}/health',
      );
      backendAvailable = response.statusCode == 200;
    } catch (_) {
      backendAvailable = false;
    }

    if (backendAvailable) {
      final uniqueEmail =
          'checkout_${DateTime.now().microsecondsSinceEpoch}@example.com';
      await authDataSource.register(
        firstName: 'Checkout',
        lastName: 'Tester',
        email: uniqueEmail,
        password: 'password123',
      );
      final (loginToken, _) = await authDataSource.login(
        email: uniqueEmail,
        password: 'password123',
      );
      token = loginToken;
      orderDio.options.headers['Authorization'] = 'Bearer $token';
    }
  });

  test('placing an order with real cart items succeeds and returns a total', () async {
    if (!backendAvailable) {
      markTestSkipped('backend not reachable at ${ApiConstants.baseUrl}');
      return;
    }

    final productsPage = await productDataSource.getProducts(offset: 0, limit: 5);
    if (productsPage.products.isEmpty) {
      markTestSkipped('no products available to order; seed the backend first');
      return;
    }

    final product = productsPage.products.first;

    final order = await orderDataSource.createOrder(
      items: [OrderLineInput(productId: product.id, quantity: 1)],
      shippingAddress: '123 Test Street, Testville',
    );

    expect(order.id, isNotEmpty);
    expect(order.status, 'pending');
    expect(order.total, greaterThan(0));
  });

  test('placing an order with an unknown product is rejected', () async {
    if (!backendAvailable) {
      markTestSkipped('backend not reachable at ${ApiConstants.baseUrl}');
      return;
    }

    await expectLater(
      orderDataSource.createOrder(
        items: [
          const OrderLineInput(
            productId: '00000000-0000-0000-0000-000000000000',
            quantity: 1,
          ),
        ],
        shippingAddress: '123 Test Street, Testville',
      ),
      throwsA(isA<Exception>()),
    );
  });
}
