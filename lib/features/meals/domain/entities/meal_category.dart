import 'package:equatable/equatable.dart';

/// A recipe category such as Beef or Seafood.
final class MealCategory extends Equatable {
  const MealCategory({
    required this.id,
    required this.name,
    required this.thumbUrl,
    required this.description,
  });

  final String id;
  final String name;
  final String thumbUrl;
  final String description;

  @override
  List<Object?> get props => [id, name, thumbUrl, description];
}
