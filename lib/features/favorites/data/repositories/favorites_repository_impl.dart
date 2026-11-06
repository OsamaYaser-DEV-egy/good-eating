import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:good_eating/features/favorites/data/models/favorite_meal_model.dart';
import 'package:good_eating/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

final class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl(this._local);

  final FavoritesLocalDataSource _local;

  @override
  Future<Result<List<MealSummary>>> getFavorites() {
    return Result.guard(() async {
      final saved = await _local.read();
      return [for (final model in saved) model.toEntity()];
    });
  }

  @override
  Future<Result<void>> saveFavorites(List<MealSummary> favorites) {
    return Result.guard(
      () => _local.write([
        for (final meal in favorites) FavoriteMealModel.fromEntity(meal),
      ]),
    );
  }
}
