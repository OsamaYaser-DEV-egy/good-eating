import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/utils/json_parsing.dart';
import 'package:good_eating/features/meals/domain/entities/ingredient.dart';
import 'package:good_eating/features/meals/domain/entities/meal_detail.dart';

/// One item of `lookup.php`.
final class MealDetailModel {
  const MealDetailModel({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbUrl,
    required this.ingredients,
    required this.tags,
    this.youtubeUrl,
    this.sourceUrl,
  });

  /// Throws [ParsingException] when the id or name is missing.
  ///
  /// Everything else is optional and falls back to an empty value, because the
  /// API leaves fields null or blank on many recipes. Newer recipes fill
  /// `strCountry` instead of `strArea`, so the area falls back to it.
  factory MealDetailModel.fromJson(Map<String, dynamic> json) {
    final id = readString(json, 'idMeal');
    final name = readString(json, 'strMeal');
    if (id == null || name == null) {
      throw const ParsingException('Meal is missing its id or name.');
    }
    return MealDetailModel(
      id: id,
      name: name,
      category: readString(json, 'strCategory') ?? '',
      area: readString(json, 'strArea') ?? readString(json, 'strCountry') ?? '',
      instructions: readString(json, 'strInstructions') ?? '',
      thumbUrl: readString(json, 'strMealThumb') ?? '',
      youtubeUrl: readString(json, 'strYoutube'),
      sourceUrl: readString(json, 'strSource'),
      tags: _parseTags(readString(json, 'strTags')),
      ingredients: _parseIngredients(json),
    );
  }

  /// The API stores ingredients as `strIngredient1..20` and `strMeasure1..20`.
  static const int _ingredientSlots = 20;

  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbUrl;
  final String? youtubeUrl;
  final String? sourceUrl;
  final List<String> tags;
  final List<Ingredient> ingredients;

  MealDetail toEntity() => MealDetail(
    id: id,
    name: name,
    category: category,
    area: area,
    instructions: instructions,
    thumbUrl: thumbUrl,
    youtubeUrl: youtubeUrl,
    sourceUrl: sourceUrl,
    tags: tags,
    ingredients: ingredients,
  );

  /// Keeps a slot only when its ingredient has a name. A missing measure is
  /// fine and becomes an empty string; a measure without a name is dropped.
  static List<Ingredient> _parseIngredients(Map<String, dynamic> json) => [
    for (var slot = 1; slot <= _ingredientSlots; slot++)
      if (readString(json, 'strIngredient$slot') case final name?)
        Ingredient(
          name: name,
          measure: readString(json, 'strMeasure$slot') ?? '',
        ),
  ];

  static List<String> _parseTags(String? raw) {
    if (raw == null) return const [];
    return [
      for (final tag in raw.split(','))
        if (tag.trim().isNotEmpty) tag.trim(),
    ];
  }
}
