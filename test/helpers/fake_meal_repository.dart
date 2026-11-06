import 'dart:async';

import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/domain/entities/ingredient.dart';
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

/// A full recipe for the meal [id] made by [fakeMeal] (`<category>-<number>`).
///
/// Every field can be overridden, so a test can ask for a recipe with no
/// video, no ingredients, a missing area and so on.
MealDetail fakeMealDetail(
  String id, {
  String? area = 'Italian',
  String? category,
  String instructions = 'Mix everything.\r\nBake it.\r\nServe warm.',
  List<Ingredient>? ingredients,
  String? youtubeUrl = 'https://www.youtube.com/watch?v=abc123',
}) {
  final parts = id.split('-');
  final categoryName = category ?? parts.first;
  final number = parts.length > 1 ? parts.last : '0';
  return MealDetail(
    id: id,
    name: '$categoryName dish $number',
    category: categoryName,
    area: area ?? '',
    instructions: instructions,
    thumbUrl: '',
    youtubeUrl: youtubeUrl,
    ingredients:
        ingredients ??
        const [
          Ingredient(name: 'flour', measure: '200g'),
          Ingredient(name: 'eggs', measure: '2'),
          Ingredient(name: 'milk', measure: ''),
        ],
  );
}

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

  /// What [getMealDetails] returns for a given id. Unlisted ids get
  /// [fakeMealDetail].
  final Map<String, Result<MealDetail>> detailsOverrides = {};
  final Map<String, Completer<Result<MealDetail>>> _heldDetails = {};

  /// Every id requested from [getMealDetails], in order.
  final List<String> requestedDetails = [];

  /// Makes [getMealDetails] for [id] wait for the completer.
  Completer<Result<MealDetail>> holdDetails(String id) =>
      _heldDetails[id] = Completer();

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
  Future<Result<MealDetail>> getMealDetails(String id) {
    requestedDetails.add(id);
    final held = _heldDetails.remove(id);
    if (held != null) return held.future;
    return Future.value(detailsOverrides[id] ?? Success(fakeMealDetail(id)));
  }

  @override
  Future<Result<List<MealSummary>>> searchMeals(String query) =>
      Future.value(const Success([]));
}
