import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/theme/app_theme.dart';
import 'package:good_eating/features/meal_details/presentation/meal_details_navigation.dart';
import 'package:good_eating/features/meal_details/presentation/pages/meal_details_page.dart';

import 'test_app_providers.dart';

/// The hero tag every test page is opened with.
const String testHeroTag = 'test-hero';

/// Opens the details screen for [mealId] on a [width] by [height] screen.
///
/// The default height is tall enough to show the whole recipe; pass a phone
/// height to test scrolling. Dependencies must already be set up with
/// `setUpDependencies`.
Future<void> pumpMealDetails(
  WidgetTester tester, {
  String mealId = 'Chicken-1',
  String name = 'Chicken dish 1',
  double width = 375,
  double height = 2400,
}) async {
  tester.view
    ..physicalSize = Size(width, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    TestAppProviders(
      child: MaterialApp(
        theme: AppTheme.light,
        home: MealDetailsPage(
          args: MealDetailsArgs(
            mealId: mealId,
            name: name,
            thumbUrl: '',
            heroTag: testHeroTag,
          ),
        ),
      ),
    ),
  );
}
