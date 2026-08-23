import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

class AddAddressUseCase implements UseCase<List<AddressEntity>, AddressEntity> {
  final AddressRepository repository;

  AddAddressUseCase(this.repository);

  @override
  Future<Either<Failure, List<AddressEntity>>> call(AddressEntity address) {
    return repository.addAddress(address);
  }
}
