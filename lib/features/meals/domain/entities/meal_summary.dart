import 'package:equatable/equatable.dart';

/// The short form of a meal shown in lists, grids and favorites.
final class MealSummary extends Equatable {
  const MealSummary({
    required this.id,
    required this.name,
    required this.thumbUrl,
  });

  final String id;
  final String name;
  final String thumbUrl;

  @override
  List<Object?> get props => [id, name, thumbUrl];
}
