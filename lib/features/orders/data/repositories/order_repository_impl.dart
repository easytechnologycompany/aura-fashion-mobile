import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required List<OrderLineInput> items,
    required String shippingAddress,
    String? paymentMethod,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final order = await remoteDataSource.createOrder(
        items: items,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      );
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
