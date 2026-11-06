import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/utils/json_parsing.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';

/// One item of `categories.php`.
final class MealCategoryModel {
  const MealCategoryModel({
    required this.id,
    required this.name,
    required this.thumbUrl,
    required this.description,
  });

  /// Throws [ParsingException] when the id or name is missing, since a
  /// category without them cannot be selected or displayed.
  factory MealCategoryModel.fromJson(Map<String, dynamic> json) {
    final id = readString(json, 'idCategory');
    final name = readString(json, 'strCategory');
    if (id == null || name == null) {
      throw const ParsingException('Category is missing its id or name.');
    }
    return MealCategoryModel(
      id: id,
      name: name,
      thumbUrl: readString(json, 'strCategoryThumb') ?? '',
      description: readString(json, 'strCategoryDescription') ?? '',
    );
  }

  final String id;
  final String name;
  final String thumbUrl;
  final String description;

  MealCategory toEntity() => MealCategory(
    id: id,
    name: name,
    thumbUrl: thumbUrl,
    description: description,
  );
}
