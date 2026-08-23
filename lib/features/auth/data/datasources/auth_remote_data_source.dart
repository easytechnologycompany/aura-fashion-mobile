import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Returns the JWT and the logged-in user.
  Future<(String token, UserModel user)> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<(String, UserModel)> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      return (token, user);
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  @override
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.register,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'phone': ?phone,
        },
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
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
