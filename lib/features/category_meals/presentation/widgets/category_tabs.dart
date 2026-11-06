import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/widgets/data_state_view.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_cubit.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';
import 'package:good_eating/features/meals/presentation/cubit/categories_cubit.dart';
import 'package:good_eating/features/meals/presentation/widgets/category_chips_row.dart';

/// The category chips wired to the app's category list and the nearest
/// [CategoryMealsCubit]. Used by Home and by the category grid, so both
/// behave identically: the tapped chip highlights at once and its meals load.
class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

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
