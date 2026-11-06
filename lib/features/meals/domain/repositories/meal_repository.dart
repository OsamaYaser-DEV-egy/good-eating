import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';
import 'package:good_eating/features/meals/domain/entities/meal_detail.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// Read access to recipes. Every method reports failure through [Result]
/// instead of throwing.
abstract interface class MealRepository {
  Future<Result<List<MealCategory>>> getCategories();

  Future<Result<List<MealSummary>>> getMealsByCategory(String category);

  /// Fails with `NotFoundFailure` when no meal has [id].
  Future<Result<MealDetail>> getMealDetails(String id);

  /// An empty list means nothing matched; it is not a failure.
  Future<Result<List<MealSummary>>> searchMeals(String query);
}
