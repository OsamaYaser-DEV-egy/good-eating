import 'package:equatable/equatable.dart';

import 'package:good_eating/core/error/failure.dart';

/// State for anything shaped like "load one thing": nothing yet, loading,
/// loaded, or failed.
sealed class DataState<T> extends Equatable {
  const DataState();

  @override
  List<Object?> get props => const [];
}

final class DataInitial<T> extends DataState<T> {
  const DataInitial();
}

final class DataLoading<T> extends DataState<T> {
  const DataLoading();
}

final class DataSuccess<T> extends DataState<T> {
  const DataSuccess(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

final class DataFailure<T> extends DataState<T> {
  const DataFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
