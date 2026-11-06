import 'package:good_eating/core/error/error_mapper.dart';
import 'package:good_eating/core/error/failure.dart';

/// The outcome of an operation that can fail: either a [Success] holding a
/// value or a [Failed] holding a [Failure].
///
/// ```dart
/// switch (await getCategories(const NoParams())) {
///   case Success(:final value): emit(DataSuccess(value));
///   case Failed(:final failure): emit(DataFailure(failure));
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Runs [action] and converts anything it throws into a [Failed] result.
  static Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on Object catch (error) {
      return Failed(ErrorMapper.map(error));
    }
  }

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => switch (this) {
    Success(:final value) => onSuccess(value),
    Failed(:final failure) => onFailure(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  final Failure failure;
}
