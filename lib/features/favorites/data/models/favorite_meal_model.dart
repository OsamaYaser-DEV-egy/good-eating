import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/utils/json_parsing.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// A saved meal as it is written to local storage.
///
/// The keys are this app's own (`id`, `name`, `thumbUrl`), not TheMealDB's, so
/// the stored data does not depend on the API's field names.
final class FavoriteMealModel {
  const FavoriteMealModel({
    required this.id,
    required this.name,
    required this.thumbUrl,
  });

  factory FavoriteMealModel.fromEntity(MealSummary meal) =>
      FavoriteMealModel(id: meal.id, name: meal.name, thumbUrl: meal.thumbUrl);

  /// Throws [ParsingException] when the id or name is missing, since a saved
  /// meal without them could not be opened or shown.
  factory FavoriteMealModel.fromJson(Map<String, dynamic> json) {
    final id = readString(json, 'id');
    final name = readString(json, 'name');
    if (id == null || name == null) {
      throw const ParsingException('Saved meal is missing its id or name.');
    }
    return FavoriteMealModel(
      id: id,
      name: name,
      thumbUrl: readString(json, 'thumbUrl') ?? '',
    );
  }

  final String id;
  final String name;
  final String thumbUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'thumbUrl': thumbUrl,
  };

  MealSummary toEntity() => MealSummary(id: id, name: name, thumbUrl: thumbUrl);
}
