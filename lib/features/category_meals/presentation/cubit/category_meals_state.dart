import 'package:equatable/equatable.dart';

import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// Which category is active, and the state of its meals.
///
/// Keeping both in one state lets a chip highlight the instant it is tapped
/// while the meals underneath show their own loading state.
final class CategoryMealsState extends Equatable {
  const CategoryMealsState({required this.selected, required this.meals});

  const CategoryMealsState.initial()
    : selected = null,
      meals = const DataInitial();

  /// The active category's name, or null before one has been chosen.
  final String? selected;
  final DataState<List<MealSummary>> meals;

  CategoryMealsState copyWith({DataState<List<MealSummary>>? meals}) =>
      CategoryMealsState(selected: selected, meals: meals ?? this.meals);

  @override
  List<Object?> get props => [selected, meals];
}
