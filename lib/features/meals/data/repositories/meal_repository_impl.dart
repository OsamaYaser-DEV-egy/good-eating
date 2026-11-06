import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/data/datasources/meal_remote_data_source.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';
import 'package:good_eating/features/meals/domain/entities/meal_detail.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/domain/repositories/meal_repository.dart';

/// Fetches recipes from TheMealDB and keeps successful responses in memory
/// for the life of the app, so revisiting a screen costs no network call.
///
/// Failures are never cached, so "Try again" always asks the server again.
/// Search results are not cached because the query space is unbounded.
final class MealRepositoryImpl implements MealRepository {
  MealRepositoryImpl(this._remote);

  final MealRemoteDataSource _remote;

  List<MealCategory>? _categories;
  final Map<String, List<MealSummary>> _mealsByCategory = {};
  final Map<String, MealDetail> _detailsById = {};

  @override
  Future<Result<List<MealCategory>>> getCategories() async {
    final cached = _categories;
    if (cached != null) return Success(cached);

    final result = await Result.guard(() async {
      final models = await _remote.getCategories();
      return [for (final model in models) model.toEntity()];
    });
    if (result case Success(:final value)) _categories = value;
    return result;
  }

  @override
  Future<Result<List<MealSummary>>> getMealsByCategory(String category) async {
    final cached = _mealsByCategory[category];
    if (cached != null) return Success(cached);

    final result = await Result.guard(() async {
      final models = await _remote.getMealsByCategory(category);
      return [for (final model in models) model.toEntity()];
    });
    if (result case Success(:final value)) _mealsByCategory[category] = value;
    return result;
  }

  @override
  Future<Result<MealDetail>> getMealDetails(String id) async {
    final cached = _detailsById[id];
    if (cached != null) return Success(cached);

    final result = await Result.guard(() => _remote.getMealDetails(id));
    switch (result) {
      case Failed(:final failure):
        return Failed(failure);
      case Success(value: null):
        return const Failed(NotFoundFailure());
      case Success(:final value?):
        final detail = value.toEntity();
        _detailsById[id] = detail;
        return Success(detail);
    }
  }

  @override
  Future<Result<List<MealSummary>>> searchMeals(String query) {
    return Result.guard(() async {
      final models = await _remote.searchMeals(query);
      return [for (final model in models) model.toEntity()];
    });
  }
}
