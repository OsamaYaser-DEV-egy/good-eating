import 'package:equatable/equatable.dart';

/// One ingredient with its quantity, for example "soy sauce" and "3/4 cup".
final class Ingredient extends Equatable {
  const Ingredient({required this.name, required this.measure});

  final String name;

  /// May be empty, because the API leaves it blank for some ingredients.
  final String measure;

  @override
  List<Object?> get props => [name, measure];
}
