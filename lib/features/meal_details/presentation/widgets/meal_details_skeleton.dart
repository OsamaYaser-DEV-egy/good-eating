import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/features/meal_details/presentation/widgets/ingredient_tile.dart';

/// Placeholder for everything below the creator row while the recipe loads:
/// the info chips, the ingredients and a few instruction lines.
class MealDetailsContentSkeleton extends StatelessWidget {
  const MealDetailsContentSkeleton({super.key});

  static const int _ingredientRows = 4;
  static const double _chipHeight = 34;
  static const double _headingWidth = 140;
  static const double _headingHeight = 24;
  static const double _lineHeight = 14;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              ShimmerBox(
                width: 84,
                height: _chipHeight,
                borderRadius: AppRadii.controlAll,
              ),
              SizedBox(width: AppSpacing.sm),
              ShimmerBox(
                width: 72,
                height: _chipHeight,
                borderRadius: AppRadii.controlAll,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          const ShimmerBox(width: _headingWidth, height: _headingHeight),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < _ingredientRows; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            const ShimmerBox(
              height: IngredientTile.minHeight,
              borderRadius: AppRadii.mdAll,
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          const ShimmerBox(width: _headingWidth, height: _headingHeight),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            const ShimmerBox(height: _lineHeight),
          ],
        ],
      ),
    );
  }
}
