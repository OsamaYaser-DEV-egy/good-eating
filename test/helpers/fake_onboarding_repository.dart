import 'dart:async';

import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/onboarding/domain/repositories/onboarding_repository.dart';

/// An in-memory [OnboardingRepository] a test can script and inspect.
final class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({this.completed = false});

  /// Whether the welcome screen counts as already seen.
  bool completed;

  /// When set, [isCompleted] returns this instead of [completed].
  Result<bool>? isCompletedResult;

  /// When set, [markCompleted] returns this instead of succeeding.
  Result<void>? markResult;

  /// How many times [markCompleted] was called.
  int markCalls = 0;

  Completer<void>? _held;

  /// Makes the next [markCompleted] wait until the returned completer is
  /// completed, so a test can look at the screen while it is saving.
  Completer<void> holdMark() => _held = Completer();

  @override
  Future<Result<bool>> isCompleted() async =>
      isCompletedResult ?? Success(completed);

  @override
  Future<Result<void>> markCompleted() async {
    markCalls++;
    final held = _held;
    if (held != null) {
      _held = null;
      await held.future;
    }

    final scripted = markResult;
    if (scripted != null) return scripted;
    completed = true;
    return const Success(null);
  }
}
