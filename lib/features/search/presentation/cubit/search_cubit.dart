import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/utils/debouncer.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/domain/usecases/search_meals.dart';
import 'package:good_eating/features/search/presentation/cubit/search_state.dart';

/// Searches meals by name as the user types.
///
/// It waits for a pause in typing before asking the server, so a word typed
/// quickly costs one request instead of one per letter. A request that is
/// still running when the text changes is not cancelled, but its answer is
/// thrown away, so the screen only ever shows results for the latest text.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required this._searchMeals, Debouncer? debouncer})
    : _debouncer = debouncer ?? Debouncer(),
      super(const SearchIdle());

  final SearchMeals _searchMeals;
  final Debouncer _debouncer;

  /// Identifies the newest request. An answer for any other number is stale.
  int _latestRequest = 0;

  /// The user typed. Searches after a pause; clearing the field resets at once.
  void onQueryChanged(String text) {
    final query = text.trim();
    if (query.isEmpty) return _reset();

    // Typed back to what is already on screen: drop any search still waiting.
    if (_isShowing(query)) return _debouncer.cancel();

    _debouncer.run(() => _run(query));
  }

  /// The user pressed the keyboard's search key. Searches without waiting.
  void submit(String text) {
    final query = text.trim();
    if (query.isEmpty) return _reset();

    _debouncer.cancel();
    if (_isShowing(query)) return;
    _run(query);
  }

  /// Tries the failed search again.
  void retry() {
    if (state is! SearchError) return;
    _debouncer.cancel();
    _run(state.query);
  }

  /// Whether [query] is already what the screen is showing or fetching. A
  /// failed search is not "shown", so typing the same text again retries it.
  bool _isShowing(String query) =>
      state.query == query && state is! SearchError && state is! SearchIdle;

  void _reset() {
    _debouncer.cancel();
    _latestRequest++;
    emit(const SearchIdle());
  }

  Future<void> _run(String query) async {
    final request = ++_latestRequest;
    emit(SearchLoading(query));

    final result = await _searchMeals(query);
    if (isClosed || request != _latestRequest) return;

    emit(switch (result) {
      Success(:final value) when value.isEmpty => SearchEmpty(query),
      Success(:final value) => SearchResults(query, List.unmodifiable(value)),
      Failed(:final failure) => SearchError(query, failure),
    });
  }

  @override
  Future<void> close() {
    _debouncer.cancel();
    return super.close();
  }
}
