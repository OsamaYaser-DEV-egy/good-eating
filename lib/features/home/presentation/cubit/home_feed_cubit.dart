import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/home/presentation/cubit/home_feed.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/domain/usecases/get_categories.dart';
import 'package:good_eating/features/meals/domain/usecases/get_meals_by_category.dart';

/// Loads the "Trending now" and "Recent recipe" carousels.
///
/// TheMealDB has no notion of trending or recent, so each carousel previews a
/// different category. The indexes avoid index 0, which is the category the
/// "Popular category" section opens on, so the same meals are not shown twice
/// on first load.
class HomeFeedCubit extends Cubit<DataState<HomeFeed>> {
  HomeFeedCubit({
    required this._getCategories,
    required this._getMealsByCategory,
  }) : super(const DataInitial());

  static const int trendingCategoryIndex = 1;
  static const int recentCategoryIndex = 2;

  /// How many meals each carousel shows.
  static const int previewSize = 5;

  final GetCategories _getCategories;
  final GetMealsByCategory _getMealsByCategory;

  /// Loads both carousels, or loads them again after a failure.
  Future<void> load() async {
    emit(const DataLoading());

    final categories = await _getCategories(const NoParams());
    if (isClosed) return;

    switch (categories) {
      case Failed(:final failure):
        emit(DataFailure(failure));
      case Success(:final value):
        final feed = await _loadFeed(value);
        if (isClosed) return;
        emit(feed);
    }
  }

  Future<DataState<HomeFeed>> _loadFeed(List<MealCategory> categories) async {
    if (categories.isEmpty) return const DataSuccess(HomeFeed.empty());

    final trendingName = _pick(categories, trendingCategoryIndex);
    final recentName = _pick(categories, recentCategoryIndex);

    final results = await Future.wait([
      _getMealsByCategory(trendingName),
      _getMealsByCategory(recentName),
    ]);

    return switch ((results[0], results[1])) {
      (Success(value: final trending), Success(value: final recent)) =>
        DataSuccess(
          HomeFeed(
            trending: _preview(trendingName, trending),
            recent: _preview(recentName, recent),
          ),
        ),
      (Failed(:final failure), _) => DataFailure(failure),
      (_, Failed(:final failure)) => DataFailure(failure),
    };
  }

  /// Wraps around, so a short category list still yields a valid name.
  String _pick(List<MealCategory> categories, int index) =>
      categories[index % categories.length].name;

  CategoryPreview _preview(String category, List<MealSummary> meals) =>
      CategoryPreview(
        category: category,
        meals: meals.take(previewSize).toList(growable: false),
      );
}
