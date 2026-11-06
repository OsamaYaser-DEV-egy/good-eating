import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/error_mapper.dart';
import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/error/failure.dart';

DioException _dioError(DioExceptionType type, {int? statusCode}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: type,
    response: statusCode == null
        ? null
        : Response<Object?>(requestOptions: options, statusCode: statusCode),
  );
}

void main() {
  group('ErrorMapper', () {
    test('maps every Dio timeout to TimeoutFailure', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(ErrorMapper.map(_dioError(type)), isA<TimeoutFailure>());
      }
    });

    test('maps a connection error to NetworkFailure', () {
      final failure = ErrorMapper.map(
        _dioError(DioExceptionType.connectionError),
      );
      expect(failure, isA<NetworkFailure>());
    });

    test('maps a 404 to NotFoundFailure', () {
      final failure = ErrorMapper.map(
        _dioError(DioExceptionType.badResponse, statusCode: 404),
      );
      expect(failure, isA<NotFoundFailure>());
    });

    test('maps a 500 to ServerFailure and keeps the status code', () {
      final failure = ErrorMapper.map(
        _dioError(DioExceptionType.badResponse, statusCode: 503),
      );
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 503);
    });

    test('maps parsing problems to ParsingFailure', () {
      expect(
        ErrorMapper.map(const ParsingException('bad')),
        isA<ParsingFailure>(),
      );
      expect(
        ErrorMapper.map(const FormatException('bad')),
        isA<ParsingFailure>(),
      );
    });

    test('maps a CacheException to CacheFailure', () {
      expect(
        ErrorMapper.map(const CacheException('disk full')),
        isA<CacheFailure>(),
      );
    });

    test('falls back to UnknownFailure and keeps the cause', () {
      final cause = StateError('boom');
      final failure = ErrorMapper.map(cause);
      expect(failure, isA<UnknownFailure>());
      expect(failure.cause, cause);
    });

    test('never exposes the raw cause in the user-facing message', () {
      final failure = ErrorMapper.map(StateError('secret internals'));
      expect(failure.message, isNot(contains('secret internals')));
    });
  });
}
