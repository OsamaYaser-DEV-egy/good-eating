import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/widgets/app_bottom_nav_bar.dart';
import 'package:good_eating/core/widgets/entrance_animation.dart';
import 'package:good_eating/features/meal_details/presentation/meal_details_navigation.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/presentation/hero_tags.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_trending_card.dart';

/// The meals that matched, one full-width card each, with their hearts.
class SearchResultsList extends StatelessWidget {
  const SearchResultsList({required this.meals, super.key});

  final List<MealSummary> meals;

  /// Only the first screenful staggers in; later cards appear straight away.
  static const int _staggeredItems = 4;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // A drag on the results closes the keyboard, so it never covers them.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppBottomNavBar.heightOf(context) + AppSpacing.md,
      ),
      itemCount: meals.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final meal = meals[index];
        final heroTag = HeroTags.meal(scope: HeroTags.search, mealId: meal.id);
        return MealTrendingCard(
          key: ValueKey(meal.id),
          meal: meal,
          heroTag: heroTag,
          onTap: () => openMealDetails(context, meal: meal, heroTag: heroTag),
        ).entrance(index: index < _staggeredItems ? index : 0);
      },
    );
  }
}
