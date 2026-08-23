import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

class GetAddressesUseCase implements UseCase<List<AddressEntity>, NoParams> {
  final AddressRepository repository;

  GetAddressesUseCase(this.repository);

  @override
  Future<Either<Failure, List<AddressEntity>>> call(NoParams params) {
    return repository.getAddresses();
  }
}
