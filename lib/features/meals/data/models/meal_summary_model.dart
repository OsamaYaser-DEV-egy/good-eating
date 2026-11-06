import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/utils/json_parsing.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// One item of `filter.php`, and the part of a `search.php` item that lists
/// need. Any other keys in the object are ignored.
final class MealSummaryModel {
  const MealSummaryModel({
    required this.id,
    required this.name,
    required this.thumbUrl,
  });

  /// Throws [ParsingException] when the id or name is missing, since a meal
  /// without them cannot be opened or displayed.
  factory MealSummaryModel.fromJson(Map<String, dynamic> json) {
    final id = readString(json, 'idMeal');
    final name = readString(json, 'strMeal');
    if (id == null || name == null) {
      throw const ParsingException('Meal is missing its id or name.');
    }
    return MealSummaryModel(
      id: id,
      name: name,
      thumbUrl: readString(json, 'strMealThumb') ?? '',
    );
  }

  final String id;
  final String name;
  final String thumbUrl;

  MealSummary toEntity() => MealSummary(id: id, name: name, thumbUrl: thumbUrl);
}
