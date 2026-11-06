import 'package:flutter/widgets.dart';

import 'package:good_eating/app/router/app_routes.dart';

/// What the category grid needs to open: which category to show first.
final class CategoryMealsArgs {
  const CategoryMealsArgs({required this.category});

  final String category;
}

/// Pushes the category grid, starting on [category].
void openCategoryMeals(BuildContext context, String category) {
  Navigator.of(context).pushNamed(
    AppRoutes.categoryMeals,
    arguments: CategoryMealsArgs(category: category),
  );
}
