import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/address_entity.dart';

abstract class AddressRepository {
  Future<Either<Failure, List<AddressEntity>>> getAddresses();
  Future<Either<Failure, List<AddressEntity>>> addAddress(AddressEntity address);
  Future<Either<Failure, List<AddressEntity>>> removeAddress(String id);
}
