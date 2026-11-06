import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/state/result_to_data_state.dart';
import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';
import 'package:good_eating/features/meals/domain/usecases/get_categories.dart';

/// The category list, shared by every screen that shows category chips.
class CategoriesCubit extends Cubit<DataState<List<MealCategory>>> {
  CategoriesCubit(this._getCategories) : super(const DataInitial());

  final GetCategories _getCategories;

  /// Loads the categories, or loads them again after a failure.
  Future<void> load() async {
    emit(const DataLoading());
    final result = await _getCategories(const NoParams());
    if (isClosed) return;
    emit(result.toDataState());
  }
}
