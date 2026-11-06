import 'dart:async';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';
import 'package:good_eating/features/meals/domain/entities/meal_detail.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/domain/repositories/meal_repository.dart';

/// Category names used by [FakeMealRepository] unless a test supplies its own.
const List<String> fakeCategoryNames = ['Beef', 'Chicken', 'Dessert', 'Lamb'];

MealCategory fakeCategory(String name) => MealCategory(
  id: 'cat-$name',
  name: name,
  thumbUrl: '',
  description: '$name recipes',
);

/// A meal with no image url, so widget tests never touch the network.
MealSummary fakeMeal(String category, int number) => MealSummary(
  id: '$category-$number',
  name: '$category dish $number',
  thumbUrl: '',
);

/// An in-memory [MealRepository] a test can script and inspect.
final class FakeMealRepository implements MealRepository {
  FakeMealRepository({
    List<String> categoryNames = fakeCategoryNames,
    this._mealsPerCategory = 6,
  }) : categoriesResult = Success([
         for (final name in categoryNames) fakeCategory(name),
       ]),
       _categoryNames = categoryNames;

  final int _mealsPerCategory;
  final List<String> _categoryNames;

  /// What [getCategories] returns. Replace it to script a failure.
  Result<List<MealCategory>> categoriesResult;

  /// Per-category overrides for [getMealsByCategory].
  final Map<String, Result<List<MealSummary>>> mealsOverrides = {};

  final Map<String, Completer<Result<List<MealSummary>>>> _held = {};
  Completer<Result<List<MealCategory>>>? _heldCategories;

  /// Every category requested from [getMealsByCategory], in order.
  final List<String> requestedCategories = [];

  int categoriesCalls = 0;

  /// Makes every [getCategories] call wait until the returned completer is
  /// completed, so a test can look at the loading state. Several cubits ask
  /// for the categories at once, and all of them must be held.
  Completer<Result<List<MealCategory>>> holdCategories() =>
      _heldCategories = Completer();

  /// Makes [getMealsByCategory] for [category] wait for the completer.
  Completer<Result<List<MealSummary>>> holdMeals(String category) =>
      _held[category] = Completer();

  List<MealSummary> defaultMeals(String category) => [
    for (var i = 1; i <= _mealsPerCategory; i++) fakeMeal(category, i),
  ];

  List<String> get categoryNames => _categoryNames;

  @override
  Future<Result<List<MealCategory>>> getCategories() {
    categoriesCalls++;
    final held = _heldCategories;
    if (held != null) return held.future;
    return Future.value(categoriesResult);
  }

  @override
  Future<Result<List<MealSummary>>> getMealsByCategory(String category) {
    requestedCategories.add(category);
    final held = _held.remove(category);
    if (held != null) return held.future;
    return Future.value(
      mealsOverrides[category] ?? Success(defaultMeals(category)),
    );
  }

  @override
  Future<Result<MealDetail>> getMealDetails(String id) =>
      Future.value(const Failed(NotFoundFailure()));

  @override
  Future<Result<List<MealSummary>>> searchMeals(String query) =>
      Future.value(const Success([]));
}
