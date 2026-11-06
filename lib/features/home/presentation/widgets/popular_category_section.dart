import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/core/widgets/data_state_view.dart';
import 'package:good_eating/core/widgets/entrance_animation.dart';
import 'package:good_eating/core/widgets/horizontal_list.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_cubit.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_state.dart';
import 'package:good_eating/features/home/presentation/widgets/home_section.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';
import 'package:good_eating/features/meals/presentation/cubit/categories_cubit.dart';
import 'package:good_eating/features/meals/presentation/widgets/category_chips_row.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_popular_card.dart';

/// "Popular category": the category tabs and, under them, that category's
/// meals. Tapping a tab selects it and loads its meals.
class PopularCategorySection extends StatelessWidget {
  const PopularCategorySection({super.key});

  /// How many meals the carousel shows for the active category.
  static const int previewSize = 10;

  @override
  Widget build(BuildContext context) {
    return const HomeSection(
      title: 'Popular category',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryTabs(),
          SizedBox(height: AppSpacing.xl),
          _CategoryMeals(),
        ],
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, DataState<List<MealCategory>>>(
      builder: (context, state) => DataStateView<List<MealCategory>>(
        state: state,
        onRetry: context.read<CategoriesCubit>().load,
        loadingBuilder: (context) => const CategoryChipsSkeleton(),
        builder: (context, categories) {
          final selected = context.select<CategoryMealsCubit, String?>(
            (cubit) => cubit.state.selected,
          );
          final cubit = context.read<CategoryMealsCubit>();
          return CategoryChipsRow(
            categories: categories,
            selected: selected,
            onSelected: (name) {
              if (name != selected) cubit.select(name);
            },
          );
        },
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
            return const SectionEmpty(
              height: MealPopularCard.height,
              message: 'No recipes in this category yet',
            );
          }
          final shown = meals
              .take(PopularCategorySection.previewSize)
              .toList(growable: false);
          return HorizontalList(
            height: MealPopularCard.height,
            itemCount: shown.length,
            itemBuilder: (context, index) =>
                MealPopularCard(meal: shown[index]).entrance(index: index),
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
    return const AppShimmer(
      child: HorizontalList(
        height: MealPopularCard.height,
        itemCount: _count,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: _skeletonItem,
      ),
    );
  }

  static Widget _skeletonItem(BuildContext context, int index) =>
      const MealPopularCardSkeleton();
}
