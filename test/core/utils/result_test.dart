import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';

void main() {
  group('Result.guard', () {
    test('wraps a returned value in Success', () async {
      final result = await Result.guard(() async => 42);
      expect(result, isA<Success<int>>());
      expect((result as Success<int>).value, 42);
    });

    test('converts a thrown error into a Failed result', () async {
      final result = await Result.guard<int>(
        () async => throw const FormatException('nope'),
      );
      expect(result, isA<Failed<int>>());
      expect((result as Failed<int>).failure, isA<ParsingFailure>());
    });
  });

  group('Result.fold', () {
    test('calls onSuccess for a Success', () {
      const Result<int> result = Success(7);
      final text = result.fold(
        onSuccess: (value) => 'ok $value',
        onFailure: (failure) => 'bad',
      );
      expect(text, 'ok 7');
    });

    test('calls onFailure for a Failed', () {
      const Result<int> result = Failed(NetworkFailure());
      final text = result.fold(
        onSuccess: (value) => 'ok',
        onFailure: (failure) => failure.message,
      );
      expect(text, const NetworkFailure().message);
    });
  });
}
