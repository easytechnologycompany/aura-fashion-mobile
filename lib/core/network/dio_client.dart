import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';

/// Wraps a configured [Dio] instance: base URL, timeouts, and an
/// interceptor that attaches the stored JWT (if any) to every request.
class DioClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  DioClient(this.secureStorage)
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout:
                const Duration(milliseconds: ApiConstants.connectTimeoutMs),
            receiveTimeout:
                const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: StorageKeys.authToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }
}
