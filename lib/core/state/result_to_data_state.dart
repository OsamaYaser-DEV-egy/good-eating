import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/utils/result.dart';

extension ResultToDataState<T> on Result<T> {
  /// The state a cubit emits once a use case has finished.
  DataState<T> toDataState() => switch (this) {
    Success(:final value) => DataSuccess(value),
    Failed(:final failure) => DataFailure(failure),
  };
}
