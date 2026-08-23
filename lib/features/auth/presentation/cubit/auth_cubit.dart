import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_cached_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCachedUserUseCase getCachedUserUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCachedUserUseCase,
  }) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    final result = await getCachedUserUseCase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.unauthenticated)),
      (user) => emit(
        user != null
            ? state.copyWith(status: AuthStatus.authenticated, user: user)
            : state.copyWith(status: AuthStatus.unauthenticated),
      ),
    );
  }

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await registerUseCase(
      RegisterParams(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(state.copyWith(status: AuthStatus.unauthenticated)),
    );
  }

  Future<void> logout() async {
    await logoutUseCase(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
