import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/favorites/domain/usecases/get_favorites.dart';
import 'package:good_eating/features/favorites/domain/usecases/save_favorites.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// The saved meals, shared by every screen so that a heart tapped in one place
/// is filled everywhere at once.
///
/// There is one instance for the whole app, provided above the navigator.
///
/// Changes show on screen immediately and are written to storage afterwards.
/// Each change writes the full list, and writes run one at a time in the order
/// they were made, so a run of quick taps always ends with the last state on
/// disk. If a write fails, the screen is put back to what is actually stored
/// and the failure is announced on [saveFailures].
class FavoritesCubit extends Cubit<DataState<List<MealSummary>>> {
  FavoritesCubit({required this._getFavorites, required this._saveFavorites})
    : super(const DataInitial());

  final GetFavorites _getFavorites;
  final SaveFavorites _saveFavorites;

  final StreamController<Failure> _saveFailures = StreamController.broadcast();

  /// The tail of the write queue. Each new write waits for the one before it.
  Future<void> _writes = Future.value();

  /// Writes that have been queued and have not finished yet.
  int _pendingWrites = 0;

  /// Emits whenever a change could not be saved, so the app can tell the user.
  Stream<Failure> get saveFailures => _saveFailures.stream;

  /// The saved meals, newest first. Empty until they have loaded.
  List<MealSummary> get favorites => switch (state) {
    DataSuccess(:final data) => data,
    _ => const [],
  };

  bool isFavorite(String mealId) => favorites.any((meal) => meal.id == mealId);

  /// Changes are ignored until the stored list has been read. Otherwise the
  /// first tap could replace everything that was saved with one meal.
  bool get _isLoaded => state is DataSuccess<List<MealSummary>>;

  /// Reads the saved meals, or reads them again after a failure.
  Future<void> load() async {
    emit(const DataLoading());
    final result = await _getFavorites(const NoParams());
    if (isClosed) return;
    emit(switch (result) {
      Success(:final value) => _loaded(value),
      Failed(:final failure) => DataFailure(failure),
    });
  }

  /// Saves [meal] if it is not saved, and removes it if it is.
  void toggle(MealSummary meal) =>
      isFavorite(meal.id) ? remove(meal.id) : add(meal);

  /// Saves [meal] at the top of the list. Does nothing if it is already saved.
  void add(MealSummary meal) {
    if (!_isLoaded || isFavorite(meal.id)) return;
    _replace([meal, ...favorites]);
  }

  /// Removes the meal with [mealId]. Does nothing if it is not saved.
  void remove(String mealId) {
    if (!_isLoaded || !isFavorite(mealId)) return;
    _replace([
      for (final meal in favorites)
        if (meal.id != mealId) meal,
    ]);
  }

  /// Saves [meal] at [index], for putting a removed meal back where it was.
  /// An index past either end is moved to the nearest end.
  void insert(MealSummary meal, int index) {
    if (!_isLoaded || isFavorite(meal.id)) return;
    final next = [...favorites];
    final position = index < 0
        ? 0
        : index > next.length
        ? next.length
        : index;
    next.insert(position, meal);
    _replace(next);
  }

  void _replace(List<MealSummary> next) {
    final snapshot = List<MealSummary>.unmodifiable(next);
    emit(DataSuccess(snapshot));

    _pendingWrites++;
    _writes = _writes.then((_) => _persist(snapshot));
  }

  Future<void> _persist(List<MealSummary> snapshot) async {
    final result = await _saveFavorites(snapshot);
    _pendingWrites--;
    if (isClosed) return;

    if (result case Failed(:final failure)) {
      _saveFailures.add(failure);
      // A newer write is still queued. It carries the newer full list, so it
      // will bring storage back in line with the screen; syncing now would
      // briefly undo changes the user can still see.
      if (_pendingWrites == 0) await _resync();
    }
  }

  /// Puts the screen back to what storage actually holds.
  Future<void> _resync() async {
    final stored = await _getFavorites(const NoParams());
    if (isClosed) return;
    if (stored case Success(:final value)) emit(_loaded(value));
  }

  /// Every list in the state is unmodifiable, so no screen can change the
  /// saved meals except through this cubit.
  DataState<List<MealSummary>> _loaded(List<MealSummary> meals) =>
      DataSuccess(List<MealSummary>.unmodifiable(meals));

  @override
  Future<void> close() {
    _saveFailures.close();
    return super.close();
  }
}
