import 'package:equatable/equatable.dart';

import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// A handful of meals taken from one category.
final class CategoryPreview extends Equatable {
  const CategoryPreview({required this.category, required this.meals});

  const CategoryPreview.empty() : category = '', meals = const [];

  final String category;
  final List<MealSummary> meals;

  @override
  List<Object?> get props => [category, meals];
}

/// The two carousels on Home that are not driven by the category chips.
final class HomeFeed extends Equatable {
  const HomeFeed({required this.trending, required this.recent});

  const HomeFeed.empty()
    : trending = const CategoryPreview.empty(),
      recent = const CategoryPreview.empty();

  final CategoryPreview trending;
  final CategoryPreview recent;

  @override
  List<Object?> get props => [trending, recent];
}
