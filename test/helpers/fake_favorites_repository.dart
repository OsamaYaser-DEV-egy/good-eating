import 'dart:async';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// A meal for favorites tests, named after its number.
MealSummary favoriteMeal(int number) =>
    MealSummary(id: 'Beef-$number', name: 'Beef dish $number', thumbUrl: '');

/// An in-memory [FavoritesRepository] a test can script and inspect.
final class FavoritesRepositoryFake implements FavoritesRepository {
  FavoritesRepositoryFake({List<MealSummary> initial = const []})
    : stored = [...initial];

  /// What is "on disk". Updated by every save that succeeds.
  List<MealSummary> stored;

  /// When set, [getFavorites] returns this instead of [stored].
  Result<List<MealSummary>>? getResult;

  /// How many of the next saves fail, in order, before saves work again.
  int failingSaves = 0;

  /// The failure a failing save reports.
  Failure saveFailure = const CacheFailure();

  /// Every list passed to [saveFavorites], in the order the calls started.
  final List<List<MealSummary>> saves = [];

  Completer<void>? _heldSave;
  Completer<void>? _heldRead;

  /// Makes the next save wait until the returned completer is completed, so a
  /// test can look at the screen while a write is still in flight.
  Completer<void> holdNextSave() => _heldSave = Completer();

  /// Makes the next read wait until the returned completer is completed, so a
  /// test can look at the loading state.
  Completer<void> holdNextRead() => _heldRead = Completer();

  @override
  Future<Result<List<MealSummary>>> getFavorites() async {
    final held = _heldRead;
    if (held != null) {
      _heldRead = null;
      await held.future;
    }
    return getResult ?? Success(List.of(stored));
  }

  @override
  Future<Result<void>> saveFavorites(List<MealSummary> favorites) async {
    saves.add(List.of(favorites));

    final held = _heldSave;
    if (held != null) {
      _heldSave = null;
      await held.future;
    }

    if (failingSaves > 0) {
      failingSaves--;
      return Failed(saveFailure);
    }
    stored = List.of(favorites);
    return const Success(null);
  }
}
