import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/widgets/app_empty_view.dart';
import 'package:good_eating/core/widgets/app_error_view.dart';
import 'package:good_eating/core/widgets/data_state_view.dart';
import 'package:good_eating/core/widgets/screen_header.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_cubit.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_state.dart';
import 'package:good_eating/features/category_meals/presentation/widgets/category_meals_grid.dart';
import 'package:good_eating/features/category_meals/presentation/widgets/category_tabs.dart';

/// The category grid screen: back arrow and category name, the category chips
/// pinned underneath, then the meals as a two-column grid.
class CategoryMealsView extends StatelessWidget {
  const CategoryMealsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BlocSelector<CategoryMealsCubit, CategoryMealsState, String?>(
              selector: (state) => state.selected,
              builder: (context, selected) =>
                  ScreenHeader(title: selected ?? ''),
            ),
            const SizedBox(height: AppSpacing.xs),
            const CategoryTabs(),
            const SizedBox(height: AppSpacing.xl),
            const Expanded(child: _MealsArea()),
          ],
        ),
      ),
    );
  }
}

class _MealsArea extends StatelessWidget {
  const _MealsArea();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryMealsCubit, CategoryMealsState>(
      buildWhen: (previous, current) => previous.meals != current.meals,
      builder: (context, state) {
        final cubit = context.read<CategoryMealsCubit>();
        return DataStateView(
          state: state.meals,
          onRetry: cubit.start,
          loadingBuilder: (context) => const CategoryMealsGridSkeleton(),
          errorBuilder: (context, failure) =>
              AppErrorView(failure: failure, onRetry: cubit.start),
          builder: (context, meals) {
            if (meals.isEmpty) {
              return const AppEmptyView(
                icon: Icons.restaurant_menu_rounded,
                title: 'No recipes here yet',
                message: 'Try another category.',
              );
            }
            return CategoryMealsGrid(meals: meals);
          },
        );
      },
    );
  }
}
