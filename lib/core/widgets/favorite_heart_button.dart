import 'package:flutter/material.dart';

import 'package:good_eating/core/constants/app_durations.dart';
import 'package:good_eating/core/theme/app_colors.dart';

/// The white circular heart that saves or removes a meal.
///
/// Sized to fit the design's bookmark slots (24 on small cards, 32 on large
/// ones). When [onPressed] is null the heart is shown but does not respond.
class FavoriteHeartButton extends StatelessWidget {
  const FavoriteHeartButton({
    required this.isFavorite,
    this.onPressed,
    this.size = 32,
    super.key,
  });

  final bool isFavorite;
  final VoidCallback? onPressed;
  final double size;

  /// Share of the circle the heart glyph fills.
  static const double _glyphRatio = 0.6;

  @override
  Widget build(BuildContext context) {
    final onPressed = this.onPressed;

    return Semantics(
      button: onPressed != null,
      label: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: AnimatedSwitcher(
                duration: AppDurations.fast,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(isFavorite),
                  size: size * _glyphRatio,
                  color: isFavorite ? AppColors.primary50 : AppColors.neutral50,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
