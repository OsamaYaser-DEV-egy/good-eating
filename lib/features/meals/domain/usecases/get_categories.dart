import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';
import 'package:good_eating/features/meals/domain/repositories/meal_repository.dart';

final class GetCategories implements UseCase<List<MealCategory>, NoParams> {
  const GetCategories(this._repository);

  final MealRepository _repository;

  @override
  Future<Result<List<MealCategory>>> call(NoParams params) =>
      _repository.getCategories();
}
