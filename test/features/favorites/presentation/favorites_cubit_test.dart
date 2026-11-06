import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/favorites/domain/usecases/get_favorites.dart';
import 'package:good_eating/features/favorites/domain/usecases/save_favorites.dart';
import 'package:good_eating/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

import '../../../helpers/fake_favorites_repository.dart';

typedef _State = DataState<List<MealSummary>>;

void main() {
  late FavoritesRepositoryFake repository;
  final m1 = favoriteMeal(1);
  final m2 = favoriteMeal(2);
  final m3 = favoriteMeal(3);
  final m4 = favoriteMeal(4);

  setUp(() => repository = FavoritesRepositoryFake());

  FavoritesCubit build() => FavoritesCubit(
    getFavorites: GetFavorites(repository),
    saveFavorites: SaveFavorites(repository),
  );

  /// A cubit that has already loaded [meals].
  Future<FavoritesCubit> loaded([List<MealSummary> meals = const []]) async {
    repository.stored = [...meals];
    final cubit = build();
    await cubit.load();
    addTearDown(cubit.close);
    return cubit;
  }

  group('loading', () {
    test('starts with nothing loaded and nothing saved', () {
      final cubit = build();
      expect(cubit.state, const DataInitial<List<MealSummary>>());
      expect(cubit.favorites, isEmpty);
    });

    blocTest<FavoritesCubit, _State>(
      'emits loading then the stored meals in stored order',
      build: () {
        repository.stored = [m2, m1];
        return build();
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const DataLoading<List<MealSummary>>(),
        DataSuccess([m2, m1]),
      ],
    );

    blocTest<FavoritesCubit, _State>(
      'an empty store loads as an empty list, not an error',
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        const DataLoading<List<MealSummary>>(),
        const DataSuccess<List<MealSummary>>([]),
      ],
    );

    blocTest<FavoritesCubit, _State>(
      'emits the failure when the stored meals cannot be read',
      build: () {
        repository.getResult = const Failed(CacheFailure());
        return build();
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const DataLoading<List<MealSummary>>(),
        const DataFailure<List<MealSummary>>(CacheFailure()),
      ],
    );

    test('recovers when loaded again after a failure', () async {
      repository.getResult = const Failed(CacheFailure());
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load();

      repository
        ..getResult = null
        ..stored = [m1];
      await cubit.load();

      expect(cubit.favorites, [m1]);
    });
  });

  group('isFavorite', () {
    test('is false for everything until the meals have loaded', () {
      final cubit = build();
      expect(cubit.isFavorite(m1.id), isFalse);
    });

    test('is true only for saved meals', () async {
      final cubit = await loaded([m1, m2]);

      expect(cubit.isFavorite(m1.id), isTrue);
      expect(cubit.isFavorite(m2.id), isTrue);
      expect(cubit.isFavorite(m3.id), isFalse);
    });
  });

  group('adding and removing', () {
    blocTest<FavoritesCubit, _State>(
      'a newly saved meal goes to the top',
      build: build,
      seed: () => DataSuccess([m1]),
      act: (cubit) => cubit
        ..add(m2)
        ..add(m3),
      expect: () => [
        DataSuccess([m2, m1]),
        DataSuccess([m3, m2, m1]),
      ],
    );

    blocTest<FavoritesCubit, _State>(
      'removing a meal keeps the order of the rest',
      build: build,
      seed: () => DataSuccess([m3, m2, m1]),
      act: (cubit) => cubit.remove(m2.id),
      expect: () => [
        DataSuccess([m3, m1]),
      ],
    );

    blocTest<FavoritesCubit, _State>(
      'toggle saves a meal that is not saved and removes one that is',
      build: build,
      seed: () => const DataSuccess<List<MealSummary>>([]),
      act: (cubit) => cubit
        ..toggle(m1)
        ..toggle(m1),
      expect: () => [
        DataSuccess([m1]),
        const DataSuccess<List<MealSummary>>([]),
      ],
    );

    blocTest<FavoritesCubit, _State>(
      'saving a meal that is already saved changes nothing',
      build: build,
      seed: () => DataSuccess([m1]),
      act: (cubit) => cubit.add(m1),
      expect: () => <_State>[],
      verify: (_) => expect(repository.saves, isEmpty),
    );

    blocTest<FavoritesCubit, _State>(
      'removing a meal that is not saved changes nothing',
      build: build,
      seed: () => DataSuccess([m1]),
      act: (cubit) => cubit.remove('Beef-99'),
      expect: () => <_State>[],
      verify: (_) => expect(repository.saves, isEmpty),
    );

    blocTest<FavoritesCubit, _State>(
      'writes the full list after every change',
      build: build,
      seed: () => const DataSuccess<List<MealSummary>>([]),
      act: (cubit) => cubit
        ..add(m1)
        ..add(m2)
        ..remove(m1.id),
      wait: const Duration(milliseconds: 20),
      verify: (_) {
        expect(repository.saves, [
          [m1],
          [m2, m1],
          [m2],
        ]);
        expect(repository.stored, [m2]);
      },
    );

    test('hands out a list that cannot be changed behind its back', () async {
      final cubit = await loaded([m1]);
      expect(() => cubit.favorites.add(m2), throwsUnsupportedError);
    });
  });

  group('putting a meal back', () {
    blocTest<FavoritesCubit, _State>(
      'insert restores a meal at its old position',
      build: build,
      seed: () => DataSuccess([m1, m2, m3]),
      act: (cubit) => cubit.insert(m4, 1),
      expect: () => [
        DataSuccess([m1, m4, m2, m3]),
      ],
    );

    blocTest<FavoritesCubit, _State>(
      'an index before the start goes to the top',
      build: build,
      seed: () => DataSuccess([m1, m2]),
      act: (cubit) => cubit.insert(m3, -5),
      expect: () => [
        DataSuccess([m3, m1, m2]),
      ],
    );

    blocTest<FavoritesCubit, _State>(
      'an index past the end goes to the bottom',
      build: build,
      seed: () => DataSuccess([m1, m2]),
      act: (cubit) => cubit.insert(m3, 99),
      expect: () => [
        DataSuccess([m1, m2, m3]),
      ],
    );

    blocTest<FavoritesCubit, _State>(
      'a meal that is already saved is not duplicated',
      build: build,
      seed: () => DataSuccess([m1, m2]),
      act: (cubit) => cubit.insert(m2, 0),
      expect: () => <_State>[],
    );

    blocTest<FavoritesCubit, _State>(
      'removing then inserting at the same index restores the list exactly',
      build: build,
      seed: () => DataSuccess([m1, m2, m3]),
      act: (cubit) => cubit
        ..remove(m2.id)
        ..insert(m2, 1),
      expect: () => [
        DataSuccess([m1, m3]),
        DataSuccess([m1, m2, m3]),
      ],
    );
  });

  group('before the stored meals have loaded', () {
    test('ignores changes, so a tap cannot wipe what was saved', () async {
      repository.stored = [m1, m2];
      final cubit = build();
      addTearDown(cubit.close);

      cubit
        ..add(m3)
        ..remove(m1.id)
        ..toggle(m4)
        ..insert(m4, 0);
      await pumpEventQueue();

      expect(cubit.state, const DataInitial<List<MealSummary>>());
      expect(repository.saves, isEmpty);
      expect(repository.stored, [m1, m2], reason: 'storage must be untouched');
    });

    test('also ignores changes after a failed load', () async {
      repository.getResult = const Failed(CacheFailure());
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load();

      cubit.add(m1);
      await pumpEventQueue();

      expect(cubit.state, isA<DataFailure<List<MealSummary>>>());
      expect(repository.saves, isEmpty);
    });
  });

  group('saving in the background', () {
    test('the screen updates before the write has finished', () async {
      final cubit = await loaded();
      final hold = repository.holdNextSave();

      cubit.add(m1);

      expect(cubit.favorites, [m1], reason: 'optimistic update');
      expect(repository.stored, isEmpty, reason: 'write is still in flight');

      hold.complete();
      await pumpEventQueue();
      expect(repository.stored, [m1]);
    });

    test(
      'writes run one at a time, in the order the changes were made',
      () async {
        final cubit = await loaded();
        final hold = repository.holdNextSave();

        cubit
          ..add(m1)
          ..add(m2)
          ..remove(m1.id);
        await pumpEventQueue();

        expect(repository.saves, [
          [m1],
        ], reason: 'later writes wait for the first');

        hold.complete();
        await pumpEventQueue();

        expect(repository.saves, [
          [m1],
          [m2, m1],
          [m2],
        ]);
        expect(repository.stored, [m2], reason: 'the last change wins');
      },
    );
  });

  group('when a save fails', () {
    test(
      'announces the failure and puts the screen back to what is stored',
      () async {
        final cubit = await loaded([m1]);
        final failures = <Failure>[];
        cubit.saveFailures.listen(failures.add);
        repository.failingSaves = 1;

        cubit.add(m2);
        expect(cubit.favorites, [m2, m1], reason: 'shown at first');
        await pumpEventQueue();

        expect(failures, [const CacheFailure()]);
        expect(cubit.favorites, [m1], reason: 'reverted to what is on disk');
        expect(repository.stored, [m1]);
      },
    );

    test('does not undo changes that a newer queued write will save', () async {
      final cubit = await loaded();
      final states = <_State>[];
      cubit.stream.listen(states.add);
      final failures = <Failure>[];
      cubit.saveFailures.listen(failures.add);

      repository.failingSaves = 1;
      final hold = repository.holdNextSave();
      cubit
        ..add(m1) // this write will fail ...
        ..add(m2); // ... but this later one carries the full list
      hold.complete();
      await pumpEventQueue();

      expect(failures, hasLength(1));
      expect(cubit.favorites, [m2, m1]);
      expect(repository.stored, [
        m2,
        m1,
      ], reason: 'the later write recovered it');
      expect(
        states,
        isNot(contains(const DataSuccess<List<MealSummary>>([]))),
        reason: 'the screen never flickered back to empty',
      );
    });

    test('announces every failure, not just the first', () async {
      final cubit = await loaded();
      final failures = <Failure>[];
      cubit.saveFailures.listen(failures.add);
      repository.failingSaves = 2;

      cubit.add(m1);
      await pumpEventQueue();
      cubit.add(m2);
      await pumpEventQueue();

      expect(failures, hasLength(2));
    });

    test('keeps working afterwards', () async {
      final cubit = await loaded();
      repository.failingSaves = 1;
      cubit.add(m1);
      await pumpEventQueue();
      expect(cubit.favorites, isEmpty);

      cubit.add(m2);
      await pumpEventQueue();

      expect(cubit.favorites, [m2]);
      expect(repository.stored, [m2]);
    });

    test('lets several listeners hear the failure', () async {
      final cubit = await loaded();
      final first = <Failure>[];
      final second = <Failure>[];
      cubit.saveFailures.listen(first.add);
      cubit.saveFailures.listen(second.add);
      repository.failingSaves = 1;

      cubit.add(m1);
      await pumpEventQueue();

      expect(first, hasLength(1));
      expect(second, hasLength(1));
    });
  });

  group('closing', () {
    test(
      'a write that finishes after closing does not throw or emit',
      () async {
        final cubit = build();
        await cubit.load();
        final hold = repository.holdNextSave();
        cubit.add(m1);

        await cubit.close();
        hold.complete();
        await pumpEventQueue();

        expect(repository.stored, [m1], reason: 'the write still completes');
      },
    );

    test('a failure that arrives after closing is dropped quietly', () async {
      final cubit = build();
      await cubit.load();
      repository.failingSaves = 1;
      final hold = repository.holdNextSave();
      cubit.add(m1);

      await cubit.close();
      hold.complete();
      await pumpEventQueue();

      expect(cubit.isClosed, isTrue);
    });

    test('closes the failure stream', () async {
      final cubit = build();
      var done = false;
      cubit.saveFailures.listen((_) {}, onDone: () => done = true);

      await cubit.close();
      await pumpEventQueue();

      expect(done, isTrue);
    });
  });
}
