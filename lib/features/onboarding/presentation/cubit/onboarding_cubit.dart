import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/features/onboarding/domain/usecases/complete_onboarding.dart';

/// Where the welcome screen is in leaving.
enum OnboardingState {
  /// Waiting for the user to tap "Start cooking".
  ready,

  /// Recording that the welcome screen has been seen.
  saving,

  /// Recorded; the screen should move on to the app.
  done,
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required this._completeOnboarding})
    : super(OnboardingState.ready);

  final CompleteOnboarding _completeOnboarding;

  /// Handles "Start cooking": records that the welcome screen was seen, then
  /// moves to [OnboardingState.done]. A second tap while this runs is ignored,
  /// so the app can never be opened twice.
  ///
  /// If the flag cannot be saved the user still goes on: the only cost is
  /// seeing the welcome screen again next time, which is better than being
  /// stuck on it.
  Future<void> start() async {
    if (state != OnboardingState.ready) return;

    emit(OnboardingState.saving);
    await _completeOnboarding(const NoParams());
    if (isClosed) return;
    emit(OnboardingState.done);
  }
}
