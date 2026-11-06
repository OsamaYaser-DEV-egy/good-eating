import 'package:dio/dio.dart';

import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/error/failure.dart';

/// Translates anything thrown in the data layer into a [Failure].
///
/// This is the only place that turns a [DioException] into a [Failure].
abstract final class ErrorMapper {
  static Failure map(Object error) => switch (error) {
    final DioException e => _fromDio(e),
    final ParsingException e => ParsingFailure(cause: e),
    final CacheException e => CacheFailure(cause: e),
    final FormatException e => ParsingFailure(cause: e),
    final TypeError e => ParsingFailure(cause: e),
    _ => UnknownFailure(cause: error),
  };

  static Failure _fromDio(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout => TimeoutFailure(cause: e),
    DioExceptionType.connectionError => NetworkFailure(cause: e),
    DioExceptionType.badResponse => _fromStatusCode(e),
    DioExceptionType.badCertificate ||
    DioExceptionType.cancel ||
    DioExceptionType.unknown => UnknownFailure(cause: e),
  };

  static Failure _fromStatusCode(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 404) return NotFoundFailure(cause: e);
    return ServerFailure(statusCode: statusCode, cause: e);
  }
}
