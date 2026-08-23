// Exercises the real AuthRemoteDataSourceImpl over HTTP against a running
// aura-fashion-backend instance. Not run as part of the default `flutter
// test` suite — start the backend first, then run explicitly:
//
//   flutter test test/integration/auth_backend_integration_test.dart \
//     --dart-define=API_BASE_URL=http://localhost:8080/api/v1
//
// Skips automatically if the backend isn't reachable.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura_fashion_mobile/core/constants/api_constants.dart';
import 'package:aura_fashion_mobile/features/auth/data/datasources/auth_remote_data_source.dart';

void main() {
  late Dio dio;
  late AuthRemoteDataSourceImpl dataSource;
  var backendAvailable = false;

  setUpAll(() async {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    dataSource = AuthRemoteDataSourceImpl(dio);
    try {
      final response = await Dio().get(
        '${ApiConstants.baseUrl.replaceFirst('/api/v1', '')}/health',
      );
      backendAvailable = response.statusCode == 200;
    } catch (_) {
      backendAvailable = false;
    }
  });

  test(
    'register then login against the live backend returns a valid token',
    () async {
      if (!backendAvailable) {
        markTestSkipped('backend not reachable at ${ApiConstants.baseUrl}');
        return;
      }

      final uniqueEmail =
          'integration_${DateTime.now().microsecondsSinceEpoch}@example.com';

      final registeredUser = await dataSource.register(
        firstName: 'Integration',
        lastName: 'Test',
        email: uniqueEmail,
        password: 'password123',
        phone: '+15550001111',
      );

      expect(registeredUser.email, uniqueEmail);
      expect(registeredUser.role, 'customer');

      final (token, loggedInUser) = await dataSource.login(
        email: uniqueEmail,
        password: 'password123',
      );

      expect(token, isNotEmpty);
      expect(loggedInUser.email, uniqueEmail);
      expect(loggedInUser.id, registeredUser.id);
    },
  );

  test(
    'login with wrong password is rejected',
    () async {
      if (!backendAvailable) {
        markTestSkipped('backend not reachable at ${ApiConstants.baseUrl}');
        return;
      }

      final uniqueEmail =
          'integration_bad_${DateTime.now().microsecondsSinceEpoch}@example.com';

      await dataSource.register(
        firstName: 'Bad',
        lastName: 'Password',
        email: uniqueEmail,
        password: 'password123',
      );

      await expectLater(
        dataSource.login(email: uniqueEmail, password: 'wrongpassword'),
        throwsA(isA<Exception>()),
      );
    },
  );
}
