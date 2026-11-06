import 'package:good_eating/core/utils/result.dart';

/// Remembers whether the user has already seen the welcome screen.
abstract interface class OnboardingRepository {
  /// False on the very first launch.
  Future<Result<bool>> isCompleted();

  /// Records that the welcome screen has been seen, so it is not shown again.
  Future<Result<void>> markCompleted();
}
