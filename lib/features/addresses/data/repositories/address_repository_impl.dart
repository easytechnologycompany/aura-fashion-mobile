import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_local_data_source.dart';
import '../models/address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressLocalDataSource localDataSource;

  AddressRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    try {
      return Right(await localDataSource.getAddresses());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> addAddress(AddressEntity address) async {
    try {
      return Right(
        await localDataSource.addAddress(AddressModel.fromEntity(address)),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> removeAddress(String id) async {
    try {
      return Right(await localDataSource.removeAddress(id));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
