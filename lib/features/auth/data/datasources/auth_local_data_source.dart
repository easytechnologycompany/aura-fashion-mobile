import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  @override
  Future<void> cacheToken(String token) {
    return secureStorage.write(key: StorageKeys.authToken, value: token);
  }

  @override
  Future<void> cacheUser(UserModel user) {
    return sharedPreferences.setString(
      StorageKeys.cachedUser,
      jsonEncode(user.toJson()),
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final raw = sharedPreferences.getString(StorageKeys.cachedUser);
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      throw const CacheException('Failed to read cached user');
    }
  }

  @override
  Future<void> clear() async {
    await secureStorage.delete(key: StorageKeys.authToken);
    await sharedPreferences.remove(StorageKeys.cachedUser);
  }
}
