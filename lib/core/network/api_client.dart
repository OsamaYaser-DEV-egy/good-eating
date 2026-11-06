import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:good_eating/core/error/exceptions.dart';

/// Thin typed wrapper over [Dio] that returns a decoded JSON object.
///
/// Failures surface as a [DioException] or [ParsingException]; the data layer
/// converts them to a `Failure` with `ErrorMapper`.
final class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<Object>(
      path,
      queryParameters: queryParameters,
    );
    return _decode(response.data);
  }

  Map<String, dynamic> _decode(Object? data) {
    // TheMealDB is not always served with a JSON content type, in which case
    // Dio hands back the raw string.
    final Object? decoded = data is String ? jsonDecode(data) : data;
    if (decoded is Map<String, dynamic>) return decoded;
    throw const ParsingException('Expected a JSON object response.');
  }
}
