import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/domain/entities/meal_detail.dart';
import 'package:good_eating/features/meals/domain/repositories/meal_repository.dart';

/// Loads one meal in full. The parameter is the meal id.
final class GetMealDetails implements UseCase<MealDetail, String> {
  const GetMealDetails(this._repository);

  final MealRepository _repository;

  @override
  Future<Result<MealDetail>> call(String id) => _repository.getMealDetails(id);
}
