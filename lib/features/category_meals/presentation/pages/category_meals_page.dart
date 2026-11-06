import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_cubit.dart';
import 'package:good_eating/features/category_meals/presentation/widgets/category_meals_view.dart';

/// Every meal in a category, opened from a "See all" button.
///
/// It owns its own [CategoryMealsCubit], so choosing a different chip here
/// does not change which category Home has selected.
class CategoryMealsPage extends StatelessWidget {
  const CategoryMealsPage({required this.category, super.key});

  /// The category to show first.
  final String category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoryMealsCubit>()..select(category),
      child: const CategoryMealsView(),
    );
  }
}
