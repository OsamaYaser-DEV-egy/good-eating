import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

final class GetFavorites implements UseCase<List<MealSummary>, NoParams> {
  const GetFavorites(this._repository);

  final FavoritesRepository _repository;

  @override
  Future<Result<List<MealSummary>>> call(NoParams params) =>
      _repository.getFavorites();
}
