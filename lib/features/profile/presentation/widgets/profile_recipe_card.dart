import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';
import 'package:good_eating/core/widgets/app_network_image.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/features/favorites/presentation/widgets/meal_favorite_heart.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_overlay_badges.dart';

/// A recipe on the profile: a wide photo darkened towards the bottom, with the
/// title and "12 Ingredients | 40 min" in white on top of it.
///
/// The ingredient count, time and rating are placeholders (see
/// `UiPlaceholders`), because the saved meal is only an id, a name and a photo.
class ProfileRecipeCard extends StatelessWidget {
  const ProfileRecipeCard({
    required this.meal,
    required this.heroTag,
    this.onTap,
    super.key,
  });

  final MealSummary meal;
  final String heroTag;
  final VoidCallback? onTap;

  static const double height = 200;

  /// The darkening starts at the bottom and is gone 110 px up.
  static const double _shadeHeight = 110;
  static const double _badgeInset = AppSpacing.sm;

  /// White at the bottom third, fading out over the rest of the shade.
  static const LinearGradient _shade = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0x99000000),
      Color(0x99000000),
      Color(0x00000000),
      Color(0x00000000),
    ],
    stops: [0, 0.38667, 0.96274, 1],
  );

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
            fit: StackFit.expand,
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: AppRadii.lgAll,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(url: meal.thumbUrl),
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: _shadeHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(gradient: _shade),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: _badgeInset,
                left: _badgeInset,
                child: MealRatingBadge(rating: UiPlaceholders.rating(meal.id)),
              ),
              Positioned(
                top: _badgeInset,
                right: _badgeInset,
                child: MealFavoriteHeart(meal: meal),
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.paragraphBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(mealId: meal.id),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "12 Ingredients | 40 min", with a thin white divider between the two.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.mealId});

  final String mealId;

  static const double _dividerHeight = 18;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.smallRegular.copyWith(color: AppColors.white);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${UiPlaceholders.ingredientCount(mealId)} Ingredients',
          style: style,
        ),
        const SizedBox(width: AppSpacing.sm),
        const SizedBox(
          width: 1,
          height: _dividerHeight,
          child: ColoredBox(color: AppColors.white),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('${UiPlaceholders.cookMinutes(mealId)} min', style: style),
      ],
    );
  }
}

/// Placeholder shown while the saved meals are read.
class ProfileRecipeCardSkeleton extends StatelessWidget {
  const ProfileRecipeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      child: ShimmerBox(
        height: ProfileRecipeCard.height,
        borderRadius: AppRadii.lgAll,
      ),
    );
  }
}
