import 'package:equatable/equatable.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// What the Search tab is showing.
sealed class SearchState extends Equatable {
  const SearchState();

  /// The text this state is about, trimmed. Empty when nothing is searched.
  String get query;

  @override
  List<Object?> get props => [query];
}

/// Nothing typed yet, or the field was cleared.
final class SearchIdle extends SearchState {
  const SearchIdle();

  @override
  String get query => '';
}

/// A request for [query] is in flight.
final class SearchLoading extends SearchState {
  const SearchLoading(this.query);

  @override
  final String query;
}

/// [query] matched [meals].
final class SearchResults extends SearchState {
  const SearchResults(this.query, this.meals);

  @override
  final String query;
  final List<MealSummary> meals;

  @override
  List<Object?> get props => [query, meals];
}

/// [query] matched nothing. This is a normal answer, not an error: TheMealDB
/// replies `{"meals": null}`, and the screen explains it kindly.
final class SearchEmpty extends SearchState {
  const SearchEmpty(this.query);

  @override
  final String query;
}

/// The request for [query] failed.
final class SearchError extends SearchState {
  const SearchError(this.query, this.failure);

  @override
  final String query;
  final Failure failure;

  @override
  List<Object?> get props => [query, failure];
}
