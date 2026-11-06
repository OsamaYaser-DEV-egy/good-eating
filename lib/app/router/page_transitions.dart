import 'package:flutter/material.dart';

import 'package:good_eating/core/constants/app_durations.dart';

/// Fades the incoming page in while it settles from a slightly smaller scale.
class FadeThroughPageRoute<T> extends PageRouteBuilder<T> {
  FadeThroughPageRoute({required WidgetBuilder builder, super.settings})
    : super(
        pageBuilder: (context, _, _) => builder(context),
        transitionDuration: AppDurations.medium,
        reverseTransitionDuration: AppDurations.medium,
        transitionsBuilder: (context, animation, _, child) {
          final curved = animation.drive(
            CurveTween(curve: Curves.easeOutCubic),
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: curved.drive(Tween<double>(begin: 0.96, end: 1)),
              child: child,
            ),
          );
        },
      );
}
