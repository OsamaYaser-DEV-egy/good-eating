/// Endpoint paths, query keys and timeouts for TheMealDB (public key `1`).
abstract final class ApiConstants {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1/';

  static const String categoriesPath = 'categories.php';
  static const String filterPath = 'filter.php';
  static const String lookupPath = 'lookup.php';
  static const String searchPath = 'search.php';

  static const String categoryQuery = 'c';
  static const String idQuery = 'i';
  static const String nameQuery = 's';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
