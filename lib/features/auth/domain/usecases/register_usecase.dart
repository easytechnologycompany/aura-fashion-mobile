import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) {
    return repository.register(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      password: params.password,
      phone: params.phone,
    );
  }
}

class RegisterParams extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? phone;

  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phone,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, password, phone];
}
