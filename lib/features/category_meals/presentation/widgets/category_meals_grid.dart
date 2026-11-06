import 'package:flutter/material.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/core/widgets/entrance_animation.dart';
import 'package:good_eating/features/meal_details/presentation/meal_details_navigation.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/presentation/hero_tags.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_popular_card.dart';

/// Two columns, 16 px apart, with every cell as tall as a popular card.
const SliverGridDelegate _delegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: CategoryMealsGrid.columns,
  crossAxisSpacing: AppSpacing.lg,
  mainAxisSpacing: AppSpacing.lg,
  mainAxisExtent: MealPopularCard.height,
);

EdgeInsets _padding(BuildContext context) => EdgeInsets.fromLTRB(
  AppSpacing.screenHorizontal,
  0,
  AppSpacing.screenHorizontal,
  AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
);

/// Every meal in a category as a two-column grid of cards.
class CategoryMealsGrid extends StatelessWidget {
  const CategoryMealsGrid({required this.meals, super.key});

  final List<MealSummary> meals;

  /// The exam asks for exactly two columns.
  static const int columns = 2;

  /// Only the first screenful staggers in. Cards that scroll into view later
  /// appear straight away rather than after a delay.
  static const int _staggeredItems = 6;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: _padding(context),
      gridDelegate: _delegate,
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        final heroTag = HeroTags.meal(scope: HeroTags.grid, mealId: meal.id);
        return MealPopularCard(
          key: ValueKey(meal.id),
          meal: meal,
          heroTag: heroTag,
          onTap: () => openMealDetails(context, meal: meal, heroTag: heroTag),
        ).entrance(index: index < _staggeredItems ? index : 0);
      },
    );
  }
}

/// Placeholder shown while a category's meals load.
class CategoryMealsGridSkeleton extends StatelessWidget {
  const CategoryMealsGridSkeleton({super.key});

  /// Three rows' worth fills a phone screen.
  static const int _count = 6;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: _padding(context),
        gridDelegate: _delegate,
        itemCount: _count,
        itemBuilder: (context, index) => const MealPopularCardSkeleton(),
      ),
    );
  }
}
