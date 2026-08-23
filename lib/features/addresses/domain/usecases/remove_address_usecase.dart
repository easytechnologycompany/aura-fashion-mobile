import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

class RemoveAddressUseCase implements UseCase<List<AddressEntity>, String> {
  final AddressRepository repository;

  RemoveAddressUseCase(this.repository);

  @override
  Future<Either<Failure, List<AddressEntity>>> call(String id) {
    return repository.removeAddress(id);
  }
}
