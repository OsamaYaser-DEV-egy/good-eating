import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/domain/usecases/search_meals.dart';
import 'package:good_eating/features/search/presentation/cubit/search_cubit.dart';
import 'package:good_eating/features/search/presentation/cubit/search_state.dart';

import '../../helpers/fake_meal_repository.dart';

const _pause = Duration(milliseconds: 300);

List<MealSummary> _matches(String query) => [
  for (var i = 1; i <= 3; i++) fakeMeal(query, i),
];

/// Runs [body] with a cubit, a repository fake and a list that collects every
/// state the cubit emits, all inside a clock the test controls.
void _scenario(
  String description,
  void Function(
    FakeAsync async,
    SearchCubit cubit,
    FakeMealRepository repository,
    List<SearchState> states,
  )
  body,
) {
  test(description, () {
    fakeAsync((async) {
      final repository = FakeMealRepository();
      final cubit = SearchCubit(searchMeals: SearchMeals(repository));
      final states = <SearchState>[];
      cubit.stream.listen(states.add);

      body(async, cubit, repository, states);

      cubit.close();
      async.flushMicrotasks();
    });
  });
}

void main() {
  test('starts idle', () {
    fakeAsync((async) {
      final cubit = SearchCubit(searchMeals: SearchMeals(FakeMealRepository()));
      expect(cubit.state, const SearchIdle());
      expect(cubit.state.query, isEmpty);
      cubit.close();
    });
  });

  group('waiting for a pause in typing', () {
    _scenario('asks nothing until typing stops', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.onQueryChanged('soup');
      async.elapse(_pause - const Duration(milliseconds: 1));
      async.flushMicrotasks();

      expect(repository.requestedSearches, isEmpty);
      expect(states, isEmpty);
    });

    _scenario('searches once the pause has passed', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.onQueryChanged('soup');
      async.elapse(_pause);
      async.flushMicrotasks();

      expect(repository.requestedSearches, ['soup']);
      expect(states, [
        const SearchLoading('soup'),
        SearchResults('soup', _matches('soup')),
      ]);
    });

    _scenario('a word typed letter by letter costs one request', (
      async,
      cubit,
      repository,
      states,
    ) {
      for (final text in ['s', 'so', 'sou', 'soup']) {
        cubit.onQueryChanged(text);
        async.elapse(const Duration(milliseconds: 100));
      }
      async.elapse(_pause);
      async.flushMicrotasks();

      expect(repository.requestedSearches, ['soup']);
    });

    _scenario('a slow typist gets a request for each pause', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.onQueryChanged('so');
      async.elapse(_pause);
      async.flushMicrotasks();
      cubit.onQueryChanged('soup');
      async.elapse(_pause);
      async.flushMicrotasks();

      expect(repository.requestedSearches, ['so', 'soup']);
    });

    _scenario('searches for the trimmed text', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.onQueryChanged('   soup \n');
      async.elapse(_pause);
      async.flushMicrotasks();

      expect(repository.requestedSearches, ['soup']);
      expect(states.last.query, 'soup');
    });
  });

  group('clearing the field', () {
    _scenario('blank text goes back to idle at once, without a request', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.onQueryChanged('soup');
      async.elapse(_pause);
      async.flushMicrotasks();

      cubit.onQueryChanged('');
      async.flushMicrotasks();

      expect(states.last, const SearchIdle());
      expect(repository.requestedSearches, ['soup']);
    });

    _scenario('whitespace only counts as blank', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.onQueryChanged('   ');
      async.elapse(_pause * 2);
      async.flushMicrotasks();

      expect(repository.requestedSearches, isEmpty);
    });

    _scenario('clearing cancels a search that was still waiting', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.onQueryChanged('soup');
      async.elapse(const Duration(milliseconds: 150));
      cubit.onQueryChanged('');
      async.elapse(_pause * 2);
      async.flushMicrotasks();

      expect(repository.requestedSearches, isEmpty);
      expect(cubit.state, const SearchIdle());
    });

    _scenario('an answer that arrives after clearing is thrown away', (
      async,
      cubit,
      repository,
      states,
    ) {
      final held = repository.holdSearch('soup');
      cubit.onQueryChanged('soup');
      async.elapse(_pause);
      async.flushMicrotasks();
      expect(cubit.state, const SearchLoading('soup'));

      cubit.onQueryChanged('');
      held.complete(Success(_matches('soup')));
      async.flushMicrotasks();

      expect(cubit.state, const SearchIdle());
    });
  });

  group('stale answers', () {
    _scenario('keeps the newest query when answers arrive out of order', (
      async,
      cubit,
      repository,
      states,
    ) {
      final slow = repository.holdSearch('so');
      cubit.onQueryChanged('so');
      async.elapse(_pause);
      async.flushMicrotasks();

      // The user keeps typing; the new request finishes first.
      cubit.onQueryChanged('soup');
      async.elapse(_pause);
      async.flushMicrotasks();
      expect(cubit.state, SearchResults('soup', _matches('soup')));

      // Now the old answer limps in.
      slow.complete(Success(_matches('so')));
      async.flushMicrotasks();

      expect(cubit.state, SearchResults('soup', _matches('soup')));
    });

    _scenario('an old failure does not replace newer results', (
      async,
      cubit,
      repository,
      states,
    ) {
      final slow = repository.holdSearch('so');
      cubit.onQueryChanged('so');
      async.elapse(_pause);
      async.flushMicrotasks();
      cubit.onQueryChanged('soup');
      async.elapse(_pause);
      async.flushMicrotasks();

      slow.complete(const Failed(NetworkFailure()));
      async.flushMicrotasks();

      expect(cubit.state, isA<SearchResults>());
    });
  });

  group('not repeating work', () {
    _scenario('typing the text that is already shown does not search again', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.onQueryChanged('soup');
      async.elapse(_pause);
      async.flushMicrotasks();

      cubit.onQueryChanged('soup ');
      async.elapse(_pause);
      async.flushMicrotasks();

      expect(repository.requestedSearches, ['soup']);
    });

    _scenario('typing back to the shown text cancels the search in between', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.onQueryChanged('soup');
      async.elapse(_pause);
      async.flushMicrotasks();

      cubit.onQueryChanged('soups');
      async.elapse(const Duration(milliseconds: 100));
      cubit.onQueryChanged('soup');
      async.elapse(_pause * 2);
      async.flushMicrotasks();

      expect(repository.requestedSearches, ['soup']);
      expect(cubit.state, SearchResults('soup', _matches('soup')));
    });

    _scenario('does not duplicate a search that is still running', (
      async,
      cubit,
      repository,
      states,
    ) {
      repository.holdSearch('soup');
      cubit.onQueryChanged('soup');
      async.elapse(_pause);
      async.flushMicrotasks();

      cubit.onQueryChanged('soup');
      async.elapse(_pause);
      async.flushMicrotasks();

      expect(repository.requestedSearches, ['soup']);
    });
  });

  group('submitting', () {
    _scenario('searches straight away, without waiting for the pause', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.submit('soup');
      async.flushMicrotasks();

      expect(repository.requestedSearches, ['soup']);
      expect(states.last, SearchResults('soup', _matches('soup')));
    });

    _scenario('replaces a search that was waiting for the pause', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.onQueryChanged('soup');
      async.elapse(const Duration(milliseconds: 100));
      cubit.submit('soup');
      async.elapse(_pause * 2);
      async.flushMicrotasks();

      expect(repository.requestedSearches, ['soup']);
    });

    _scenario('blank text resets instead of searching', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.submit('  ');
      async.flushMicrotasks();

      expect(repository.requestedSearches, isEmpty);
      expect(cubit.state, const SearchIdle());
    });
  });

  group('outcomes', () {
    _scenario('no matches is its own state, not an error', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.submit('zzzz');
      async.flushMicrotasks();

      expect(states, [const SearchLoading('zzzz'), const SearchEmpty('zzzz')]);
    });

    _scenario('a failed request becomes an error that remembers the query', (
      async,
      cubit,
      repository,
      states,
    ) {
      repository.searchOverrides['soup'] = const Failed(TimeoutFailure());

      cubit.submit('soup');
      async.flushMicrotasks();

      expect(states.last, const SearchError('soup', TimeoutFailure()));
    });

    _scenario('retry searches the failed query again and recovers', (
      async,
      cubit,
      repository,
      states,
    ) {
      repository.searchOverrides['soup'] = const Failed(NetworkFailure());
      cubit.submit('soup');
      async.flushMicrotasks();
      repository.searchOverrides.remove('soup');

      cubit.retry();
      async.flushMicrotasks();

      expect(repository.requestedSearches, ['soup', 'soup']);
      expect(cubit.state, SearchResults('soup', _matches('soup')));
    });

    _scenario('retry does nothing when there is no error', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.retry();
      cubit.submit('soup');
      async.flushMicrotasks();
      cubit.retry();
      async.flushMicrotasks();

      expect(repository.requestedSearches, ['soup']);
    });

    _scenario('typing the same text again retries after a failure', (
      async,
      cubit,
      repository,
      states,
    ) {
      repository.searchOverrides['soup'] = const Failed(NetworkFailure());
      cubit.submit('soup');
      async.flushMicrotasks();
      repository.searchOverrides.remove('soup');

      cubit.onQueryChanged('soup');
      async.elapse(_pause);
      async.flushMicrotasks();

      expect(cubit.state, SearchResults('soup', _matches('soup')));
    });

    _scenario('hands out a results list that cannot be changed', (
      async,
      cubit,
      repository,
      states,
    ) {
      cubit.submit('soup');
      async.flushMicrotasks();

      final results = cubit.state as SearchResults;
      expect(() => results.meals.add(fakeMeal('x', 1)), throwsUnsupportedError);
    });
  });

  group('closing', () {
    test('cancels a search that was waiting for the pause', () {
      fakeAsync((async) {
        final repository = FakeMealRepository();
        final cubit = SearchCubit(searchMeals: SearchMeals(repository));

        cubit.onQueryChanged('soup');
        cubit.close();
        async.elapse(_pause * 2);
        async.flushMicrotasks();

        expect(repository.requestedSearches, isEmpty);
      });
    });

    test('an answer that arrives after closing is dropped quietly', () {
      fakeAsync((async) {
        final repository = FakeMealRepository();
        final held = repository.holdSearch('soup');
        final cubit = SearchCubit(searchMeals: SearchMeals(repository));
        cubit.submit('soup');
        async.flushMicrotasks();

        cubit.close();
        held.complete(Success(_matches('soup')));
        async.flushMicrotasks();

        expect(cubit.isClosed, isTrue);
        expect(cubit.state, const SearchLoading('soup'));
      });
    });
  });
}
