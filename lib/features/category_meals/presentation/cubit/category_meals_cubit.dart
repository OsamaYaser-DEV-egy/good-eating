import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/state/result_to_data_state.dart';
import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_state.dart';
import 'package:good_eating/features/meals/domain/usecases/get_categories.dart';
import 'package:good_eating/features/meals/domain/usecases/get_meals_by_category.dart';

/// Tracks the active category and loads its meals.
class CategoryMealsCubit extends Cubit<CategoryMealsState> {
  CategoryMealsCubit({
    required this._getCategories,
    required this._getMealsByCategory,
  }) : super(const CategoryMealsState.initial());

  final GetCategories _getCategories;
  final GetMealsByCategory _getMealsByCategory;

  /// Begins on the first category, or reloads the current one.
  ///
  /// Safe to call again after a failure, which is what "Try again" does.
  Future<void> start() async {
    final current = state.selected;
    if (current != null) return select(current);

    emit(state.copyWith(meals: const DataLoading()));
    final categories = await _getCategories(const NoParams());
    if (isClosed) return;

    switch (categories) {
      case Success(:final value) when value.isNotEmpty:
        await select(value.first.name);
      case Success():
        emit(state.copyWith(meals: const DataSuccess([])));
      case Failed(:final failure):
        emit(state.copyWith(meals: DataFailure(failure)));
    }
  }

  /// Makes [category] active immediately and loads its meals.
  ///
  /// If another category is chosen before the request finishes, the late
  /// answer is discarded so the screen never shows the wrong meals.
  Future<void> select(String category) async {
    emit(CategoryMealsState(selected: category, meals: const DataLoading()));
    final result = await _getMealsByCategory(category);
    if (isClosed || state.selected != category) return;
    emit(state.copyWith(meals: result.toDataState()));
  }
}
