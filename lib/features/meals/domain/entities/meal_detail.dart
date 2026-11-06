import 'package:equatable/equatable.dart';

import 'package:good_eating/features/meals/domain/entities/ingredient.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/domain/utils/instruction_steps.dart';

/// Everything known about one meal.
final class MealDetail extends Equatable {
  const MealDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbUrl,
    required this.ingredients,
    this.tags = const [],
    this.youtubeUrl,
    this.sourceUrl,
  });

  final String id;
  final String name;
  final String category;

  /// Country of origin, for example "Japanese".
  final String area;
  final String instructions;
  final String thumbUrl;

  /// Only ingredients that have a name; the API's empty slots are dropped.
  final List<Ingredient> ingredients;
  final List<String> tags;

  /// Null when the recipe has no video.
  final String? youtubeUrl;
  final String? sourceUrl;

  /// The instructions broken into numbered-ready steps.
  List<String> get instructionSteps => splitInstructionSteps(instructions);

  /// The form saved to favorites and shown in lists.
  MealSummary toSummary() =>
      MealSummary(id: id, name: name, thumbUrl: thumbUrl);

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    area,
    instructions,
    thumbUrl,
    ingredients,
    tags,
    youtubeUrl,
    sourceUrl,
  ];
}
