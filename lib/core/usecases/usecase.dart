import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// A use case that takes [Params] and returns either a [Failure] or [Result].
abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

/// Marker for use cases that take no parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
