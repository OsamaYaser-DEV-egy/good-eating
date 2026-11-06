import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:good_eating/core/constants/app_durations.dart';

/// A staggered fade and slide-up for items appearing together.
extension EntranceAnimation on Widget {
  /// Items past [_maxStaggered] share the last delay, so a long list never
  /// makes the user wait for its tail.
  static const int _maxStaggered = 8;

  Widget entrance({int index = 0}) {
    final step = math.min(index, _maxStaggered);
    return animate(delay: AppDurations.stagger * step)
        .fadeIn(duration: AppDurations.medium, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: AppDurations.medium,
          curve: Curves.easeOutCubic,
        );
  }
}
