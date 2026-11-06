import 'dart:async';

import 'package:good_eating/core/constants/app_durations.dart';

/// Delays an action until calls stop arriving for [duration].
final class Debouncer {
  Debouncer({this.duration = AppDurations.searchDebounce});

  final Duration duration;
  Timer? _timer;

  /// Schedules [action], cancelling any action still waiting.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Drops the pending action, if any.
  void cancel() => _timer?.cancel();
}
