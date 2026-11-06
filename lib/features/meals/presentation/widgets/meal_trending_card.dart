import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:good_eating/core/constants/app_assets.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';
import 'package:good_eating/core/widgets/app_network_image.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/features/favorites/presentation/widgets/meal_favorite_heart.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/presentation/widgets/creator_line.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_overlay_badges.dart';

/// The large card in "Trending now" and in the Saved list: a wide photo with a
/// play button, rating, heart and video length, then the title and creator
/// underneath.
///
/// It fills the width it is given, so a carousel wraps it in a
/// [carouselWidth] box and the Saved list lets it span the screen.
///
/// The play button, rating, video length and creator are placeholders (see
/// `UiPlaceholders`), because TheMealDB does not return them.
class MealTrendingCard extends StatelessWidget {
  const MealTrendingCard({
    required this.meal,
    required this.heroTag,
    this.onTap,
    this.onFavoriteRemoved,
    super.key,
  });

  final MealSummary meal;

  /// Tag of the photo's `Hero`; the details screen must be opened with the
  /// same one.
  final String heroTag;
  final VoidCallback? onTap;

  /// Called after the heart is tapped to remove the meal, for the Saved list
  /// to offer an undo.
  final VoidCallback? onFavoriteRemoved;

  /// The card's width in the "Trending now" carousel.
  static const double carouselWidth = 280;
  static const double height = 254;
  static const double imageHeight = 180;

  /// Inset of the badges from the photo's edges.
  static const double _badgeInset = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: meal.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: AppRadii.lgAll,
                      child: AppNetworkImage(url: meal.thumbUrl),
                    ),
                  ),
                  Center(
                    child: ExcludeSemantics(
                      child: SvgPicture.asset(AppAssets.playButton),
                    ),
                  ),
                  Positioned(
                    top: _badgeInset,
                    left: _badgeInset,
                    child: MealRatingBadge(
                      rating: UiPlaceholders.rating(meal.id),
                    ),
                  ),
                  Positioned(
                    top: _badgeInset,
                    right: _badgeInset,
                    child: MealFavoriteHeart(
                      meal: meal,
                      onRemoved: onFavoriteRemoved,
                    ),
                  ),
                  Positioned(
                    bottom: _badgeInset,
                    right: _badgeInset,
                    child: MealDurationBadge(
                      duration: UiPlaceholders.videoLength(meal.id),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    meal.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.paragraphBold,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ExcludeSemantics(child: SvgPicture.asset(AppAssets.more)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            CreatorLine(creator: UiPlaceholders.creator(meal.id)),
          ],
        ),
      ),
    );
  }
}

/// Placeholder shown while the trending meals load.
class MealTrendingCardSkeleton extends StatelessWidget {
  const MealTrendingCardSkeleton({super.key});

  static const double _titleWidth = 200;
  static const double _titleHeight = 20;
  static const double _creatorWidth = 120;
  static const double _creatorHeight = 12;
  static const double _avatarSize = 32;

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(
          height: MealTrendingCard.imageHeight,
          borderRadius: AppRadii.lgAll,
        ),
        SizedBox(height: AppSpacing.md),
        ShimmerBox(width: _titleWidth, height: _titleHeight),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            ShimmerBox.circle(diameter: _avatarSize),
            SizedBox(width: AppSpacing.sm),
            ShimmerBox(width: _creatorWidth, height: _creatorHeight),
          ],
        ),
      ],
    );
  }
}
