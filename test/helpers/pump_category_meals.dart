import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/theme/app_theme.dart';
import 'package:good_eating/features/category_meals/presentation/pages/category_meals_page.dart';

import 'test_app_providers.dart';

/// Builds the category grid the way the app does, with the shared cubits above
/// it. Dependencies must already be set up with `setUpDependencies`.
///
/// The screen is [width] by [height] logical pixels.
Future<void> pumpCategoryMeals(
  WidgetTester tester, {
  required String category,
  double width = 375,
  double height = 812,
}) async {
  tester.view
    ..physicalSize = Size(width, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    TestAppProviders(
      child: MaterialApp(
        theme: AppTheme.light,
        home: CategoryMealsPage(category: category),
      ),
    ),
  );
}
