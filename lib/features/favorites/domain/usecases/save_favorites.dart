import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// Saves the full list of favorites, replacing what was stored before.
final class SaveFavorites implements UseCase<void, List<MealSummary>> {
  const SaveFavorites(this._repository);

  final FavoritesRepository _repository;

  @override
  Future<Result<void>> call(List<MealSummary> favorites) =>
      _repository.saveFavorites(favorites);
}
