/// Central place for backend endpoint configuration.
///
/// Points at the aura-fashion-backend Go API. Override [baseUrl] per
/// environment (e.g. via --dart-define=API_BASE_URL=...) as needed.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );

  static const String register = '/auth/register';
  static const String login = '/auth/login';

  static const String products = '/products';
  static String product(String id) => '/products/$id';

  static const String orders = '/orders';
  static String order(String id) => '/orders/$id';

  static const connectTimeoutMs = 15000;
  static const receiveTimeoutMs = 15000;
}

class StorageKeys {
  StorageKeys._();

  static const authToken = 'auth_token';
  static const cachedUser = 'cached_user';
}
