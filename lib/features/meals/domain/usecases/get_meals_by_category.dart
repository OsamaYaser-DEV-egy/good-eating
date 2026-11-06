import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/domain/repositories/meal_repository.dart';

/// Loads the meals in one category. The parameter is the category name.
final class GetMealsByCategory implements UseCase<List<MealSummary>, String> {
  const GetMealsByCategory(this._repository);

  final MealRepository _repository;

  @override
  Future<Result<List<MealSummary>>> call(String category) =>
      _repository.getMealsByCategory(category);
}
