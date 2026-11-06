import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// The meals the user has saved, kept on this device.
///
/// The repository only reads and replaces the whole list. Deciding what the
/// list should contain, and in what order, is the cubit's job, so a quick run
/// of taps cannot interleave two read-modify-write cycles.
abstract interface class FavoritesRepository {
  /// Newest first. An unreadable store is an empty list, not a failure, so a
  /// corrupt file can never lock the user out of saving again.
  Future<Result<List<MealSummary>>> getFavorites();

  /// Replaces everything that was saved with [favorites], in that order.
  Future<Result<void>> saveFavorites(List<MealSummary> favorites);
}
