import 'package:flutter/widgets.dart';

import 'package:good_eating/app/router/app_routes.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// What the details screen needs to open.
///
/// The name and photo are already known from the list the user tapped, so the
/// screen can show them at once and the photo can fly in as a hero while the
/// full recipe loads.
final class MealDetailsArgs {
  const MealDetailsArgs({
    required this.mealId,
    required this.name,
    required this.thumbUrl,
    required this.heroTag,
  });

  final String mealId;
  final String name;
  final String thumbUrl;

  /// Matches the tag on the photo that was tapped.
  final String heroTag;
}

/// Pushes the details screen for [meal]. [heroTag] must match the tag on the
/// photo the user tapped, so that photo animates into the screen.
void openMealDetails(
  BuildContext context, {
  required MealSummary meal,
  required String heroTag,
}) {
  Navigator.of(context).pushNamed(
    AppRoutes.mealDetails,
    arguments: MealDetailsArgs(
      mealId: meal.id,
      name: meal.name,
      thumbUrl: meal.thumbUrl,
      heroTag: heroTag,
    ),
  );
}
