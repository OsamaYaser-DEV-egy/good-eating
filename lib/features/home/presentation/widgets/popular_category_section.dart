import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/core/widgets/data_state_view.dart';
import 'package:good_eating/core/widgets/entrance_animation.dart';
import 'package:good_eating/core/widgets/horizontal_list.dart';
import 'package:good_eating/features/category_meals/presentation/category_meals_navigation.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_cubit.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_state.dart';
import 'package:good_eating/features/category_meals/presentation/widgets/category_tabs.dart';
import 'package:good_eating/features/home/presentation/widgets/home_section.dart';
import 'package:good_eating/features/meal_details/presentation/meal_details_navigation.dart';
import 'package:good_eating/features/meals/presentation/hero_tags.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_popular_card.dart';

/// "Popular category": the category tabs and, under them, that category's
/// meals. Tapping a tab selects it and loads its meals; "See all" opens the
/// selected category as a grid.
class PopularCategorySection extends StatelessWidget {
  const PopularCategorySection({super.key});

  /// How many meals the carousel shows for the active category.
  static const int previewSize = 10;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CategoryMealsCubit, CategoryMealsState, String?>(
      selector: (state) => state.selected,
      builder: (context, selected) => HomeSection(
        title: 'Popular category',
        onSeeAll: selected == null
            ? null
            : () => openCategoryMeals(context, selected),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryTabs(),
            SizedBox(height: AppSpacing.xl),
            _CategoryMeals(),
          ],
        ),
      ),
    );
  }
}

class _CategoryMeals extends StatelessWidget {
  const _CategoryMeals();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryMealsCubit, CategoryMealsState>(
      buildWhen: (previous, current) => previous.meals != current.meals,
      builder: (context, state) => DataStateView(
        state: state.meals,
        onRetry: context.read<CategoryMealsCubit>().start,
        loadingBuilder: (context) => const _MealsSkeleton(),
        builder: (context, meals) {
          if (meals.isEmpty) {
            return SectionEmpty(
              height: MealPopularCard.heightOf(context),
              message: 'No recipes in this category yet',
            );
          }
          final shown = meals
              .take(PopularCategorySection.previewSize)
              .toList(growable: false);
          return HorizontalList(
            height: MealPopularCard.heightOf(context),
            itemCount: shown.length,
            itemBuilder: (context, index) {
              final meal = shown[index];
              final heroTag = HeroTags.meal(
                scope: HeroTags.popular,
                mealId: meal.id,
              );
              return SizedBox(
                width: MealPopularCard.carouselWidth,
                child: MealPopularCard(
                  meal: meal,
                  heroTag: heroTag,
                  onTap: () =>
                      openMealDetails(context, meal: meal, heroTag: heroTag),
                ),
              ).entrance(index: index);
            },
          );
        },
      ),
    );
  }
}

class _MealsSkeleton extends StatelessWidget {
  const _MealsSkeleton();

  static const int _count = 2;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: HorizontalList(
        height: MealPopularCard.heightOf(context),
        itemCount: _count,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: _skeletonItem,
      ),
    );
  }

  static Widget _skeletonItem(BuildContext context, int index) =>
      const SizedBox(
        width: MealPopularCard.carouselWidth,
        child: MealPopularCardSkeleton(),
      );
}
