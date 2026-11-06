import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/state/result_to_data_state.dart';
import 'package:good_eating/features/meals/domain/entities/meal_detail.dart';
import 'package:good_eating/features/meals/domain/usecases/get_meal_details.dart';

/// Loads one meal in full.
class MealDetailsCubit extends Cubit<DataState<MealDetail>> {
  MealDetailsCubit({required this._getMealDetails, required this.mealId})
    : super(const DataInitial());

  final GetMealDetails _getMealDetails;
  final String mealId;

  /// Loads the meal, or loads it again after a failure.
  Future<void> load() async {
    emit(const DataLoading());
    final result = await _getMealDetails(mealId);
    if (isClosed) return;
    emit(result.toDataState());
  }
}
