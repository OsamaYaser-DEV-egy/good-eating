import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/formatters.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';
import 'package:good_eating/core/widgets/app_network_image.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/core/widgets/favorite_heart_button.dart';
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
    this.isFavorite = false,
    this.onFavoriteToggle,
    super.key,
  });

  final MealSummary meal;

  /// Tag of the dish photo's `Hero`; the details screen must be opened with
  /// the same one.
  final String heroTag;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  /// The card's width in the "Popular category" carousel.
  static const double carouselWidth = 150;
  static const double height = 231;

  static const double _dishSize = 110;

  /// The grey panel starts halfway down the dish, so the photo overlaps it.
  static const double _panelTop = 55;
  static const double _titleTop = height - _dishSize;
  static const double _panelPadding = AppSpacing.md;
  static const double _titleInset = AppSpacing.sm;
  static const double _heartSize = 24;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: meal.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: height,
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
                child: FavoriteHeartButton(
                  isFavorite: isFavorite,
                  onPressed: onFavoriteToggle,
                  size: _heartSize,
                ),
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
    return const SizedBox(
      height: MealPopularCard.height,
      child: Stack(
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
