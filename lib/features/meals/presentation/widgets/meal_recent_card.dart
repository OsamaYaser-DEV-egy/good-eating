import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/text_scaling.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';
import 'package:good_eating/core/widgets/app_network_image.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// The compact card in "Recent recipe": a square photo, a two-line title and
/// "By creator".
///
/// The creator is a placeholder (see `UiPlaceholders`).
class MealRecentCard extends StatelessWidget {
  const MealRecentCard({
    required this.meal,
    required this.heroTag,
    this.onTap,
    super.key,
  });

  final MealSummary meal;

  /// Tag of the photo's `Hero`; the details screen must be opened with the
  /// same one.
  final String heroTag;
  final VoidCallback? onTap;

  static const double width = 124;

  /// The title always reserves two lines (14 px at 1.4), so every card's
  /// creator line sits at the same height.
  static const double _titleLines = 14 * 1.4 * 2;

  /// One line of the 10 px "By creator" text at its natural height.
  static const double _creatorLine = 10 * 1.5;

  /// The card's height: about 191 at the default text size, taller for larger
  /// text.
  static double heightOf(BuildContext context) =>
      width +
      AppSpacing.sm +
      context.scaled(_titleLines) +
      AppSpacing.xs +
      context.scaled(_creatorLine);

  /// Text is inset slightly from the photo's edge in the design.
  static const double _textInset = AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: meal.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: AppRadii.mdAll,
                  child: SizedBox.square(
                    dimension: width,
                    child: AppNetworkImage(url: meal.thumbUrl),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _textInset),
                child: SizedBox(
                  height: context.scaled(_titleLines),
                  child: Text(
                    meal.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelBold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _textInset),
                child: Text(
                  'By ${UiPlaceholders.creator(meal.id).name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.tinyRegular.copyWith(
                    color: AppColors.neutral40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder shown while the recent meals load.
class MealRecentCardSkeleton extends StatelessWidget {
  const MealRecentCardSkeleton({super.key});

  static const double _titleWidth = 100;
  static const double _titleHeight = 14;
  static const double _creatorWidth = 70;
  static const double _creatorHeight = 10;

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: MealRecentCard.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: MealRecentCard.width,
            height: MealRecentCard.width,
            borderRadius: AppRadii.mdAll,
          ),
          SizedBox(height: AppSpacing.sm),
          ShimmerBox(width: _titleWidth, height: _titleHeight),
          SizedBox(height: AppSpacing.sm),
          ShimmerBox(width: _creatorWidth, height: _creatorHeight),
        ],
      ),
    );
  }
}
