import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/formatters.dart';
import 'package:good_eating/core/utils/text_scaling.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';
import 'package:good_eating/core/widgets/app_network_image.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/features/favorites/presentation/widgets/meal_favorite_heart.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// The tall grey card used in "Popular category" and in the category grid: a
/// round dish photo overlapping the top of a panel with the title, cook time
/// and heart.
///
/// It fills the width it is given, so a carousel wraps it in a [carouselWidth]
/// box and a grid lets each cell decide.
///
/// The cook time is a placeholder (see `UiPlaceholders`).
class MealPopularCard extends StatelessWidget {
  const MealPopularCard({
    required this.meal,
    required this.heroTag,
    this.onTap,
    super.key,
  });

  final MealSummary meal;

  /// Tag of the dish photo's `Hero`; the details screen must be opened with
  /// the same one.
  final String heroTag;
  final VoidCallback? onTap;

  /// The card's width in the "Popular category" carousel.
  static const double carouselWidth = 150;

  static const double _dishSize = 110;

  /// The grey panel starts halfway down the dish, so the photo overlaps it.
  static const double _panelTop = 55;

  /// The title starts 11 px below the dish, 121 px from the card's top.
  static const double _titleTop = _dishSize + 11;
  static const double _panelPadding = AppSpacing.md;
  static const double _titleInset = AppSpacing.sm;
  static const double _heartSize = 24;

  /// The text parts of the card's height, which grow with the text size.
  static const double _titleLines = 14 * 1.4 * 2;
  static const double _timeLine = 12 * 1.5;
  static const double _timeGap = AppSpacing.xs;

  /// Space between the title and the time block at the default text size.
  static const double _titleToTime = 18.8;

  /// The card's height: 231 at the default text size, taller for larger text
  /// so the title and the time never run into each other or off the card.
  static double heightOf(BuildContext context) =>
      _titleTop +
      context.scaled(_titleLines) +
      _titleToTime +
      2 * context.scaled(_timeLine) +
      _timeGap +
      _panelPadding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: meal.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: heightOf(context),
          child: Stack(
            children: [
              const Positioned(
                top: _panelTop,
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.neutral10,
                    borderRadius: AppRadii.mdAll,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Hero(
                    tag: heroTag,
                    child: _Dish(url: meal.thumbUrl),
                  ),
                ),
              ),
              Positioned(
                top: _titleTop,
                left: _titleInset,
                right: _titleInset,
                child: Text(
                  meal.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelBold,
                ),
              ),
              Positioned(
                left: _panelPadding,
                bottom: _panelPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Time',
                      style: AppTextStyles.smallRegular.copyWith(
                        color: AppColors.neutral30,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      Formatters.cookTime(UiPlaceholders.cookMinutes(meal.id)),
                      style: AppTextStyles.smallBold,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: _panelPadding,
                bottom: _panelPadding,
                child: MealFavoriteHeart(meal: meal, size: _heartSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dish extends StatelessWidget {
  const _Dish({required this.url});

  final String url;

  static const double _shadowBlur = 16;
  static const double _shadowOffset = 8;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x26181818),
            blurRadius: _shadowBlur,
            offset: Offset(0, _shadowOffset),
          ),
        ],
      ),
      child: ClipOval(
        child: SizedBox.square(
          dimension: MealPopularCard._dishSize,
          child: AppNetworkImage(url: url),
        ),
      ),
    );
  }
}

/// Placeholder shown while the category's meals load.
class MealPopularCardSkeleton extends StatelessWidget {
  const MealPopularCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MealPopularCard.heightOf(context),
      child: const Stack(
        children: [
          Positioned(
            top: MealPopularCard._panelTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: ShimmerBox(borderRadius: AppRadii.mdAll),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: ShimmerBox.circle(diameter: MealPopularCard._dishSize),
            ),
          ),
        ],
      ),
    );
  }
}
