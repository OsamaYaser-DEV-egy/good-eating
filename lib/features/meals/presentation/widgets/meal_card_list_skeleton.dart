import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_trending_card.dart';

/// Placeholder for a vertical list of full-width meal cards, shown while the
/// saved meals or the search results load.
class MealCardListSkeleton extends StatelessWidget {
  const MealCardListSkeleton({super.key});

  /// Two cards fill the space under the heading on a phone.
  static const int _count = 2;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          0,
        ),
        itemCount: _count,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.lg),
        itemBuilder: (context, index) => const MealTrendingCardSkeleton(),
      ),
    );
  }
}
