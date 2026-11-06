import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';

/// A small frosted pill laid over a photo, for ratings and durations.
class OverlayBadge extends StatelessWidget {
  const OverlayBadge({required this.child, super.key});

  final Widget child;

  static const double _blurSigma = 2.5;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.smAll,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
        child: ColoredBox(
          color: AppColors.overlayScrim,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
