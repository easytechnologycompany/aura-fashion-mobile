import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required List<OrderLineInput> items,
    required String shippingAddress,
    String? paymentMethod,
  });

  Future<OrderModel> getOrder(String id);

  Future<List<OrderModel>> listOrders({int offset = 0, int limit = 20});
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl(this.dio);

  @override
  Future<OrderModel> createOrder({
    required List<OrderLineInput> items,
    required String shippingAddress,
    String? paymentMethod,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.orders,
        data: {
          'shipping_address': shippingAddress,
          'payment_method': ?paymentMethod,
          'items': items
              .map((i) => {'product_id': i.productId, 'quantity': i.quantity})
              .toList(),
        },
      );
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  @override
  Future<OrderModel> getOrder(String id) async {
    try {
      final response = await dio.get(ApiConstants.order(id));
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  @override
  Future<List<OrderModel>> listOrders({int offset = 0, int limit = 20}) async {
    try {
      final response = await dio.get(
        ApiConstants.orders,
        queryParameters: {'offset': offset, 'limit': limit},
      );
      final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
      return data
          .map((o) => OrderModel.fromJson(o as Map<String, dynamic>))
          .toList();
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
