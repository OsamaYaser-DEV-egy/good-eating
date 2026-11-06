import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:good_eating/features/favorites/data/models/favorite_meal_model.dart';
import 'package:good_eating/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

class _FakeLocalDataSource implements FavoritesLocalDataSource {
  List<FavoriteMealModel> stored = [];
  Object? readError;
  Object? writeError;

  @override
  Future<List<FavoriteMealModel>> read() async {
    final error = readError;
    if (error != null) throw error;
    return List.of(stored);
  }

  @override
  Future<void> write(List<FavoriteMealModel> favorites) async {
    final error = writeError;
    if (error != null) throw error;
    stored = List.of(favorites);
  }
}

const _soup = MealSummary(id: '1', name: 'Soup', thumbUrl: 'soup.jpg');
const _stew = MealSummary(id: '2', name: 'Stew', thumbUrl: 'stew.jpg');

void main() {
  late _FakeLocalDataSource local;
  late FavoritesRepositoryImpl repository;

  setUp(() {
    local = _FakeLocalDataSource();
    repository = FavoritesRepositoryImpl(local);
  });

  test('reads saved meals as entities, in stored order', () async {
    local.stored = [
      FavoriteMealModel.fromEntity(_stew),
      FavoriteMealModel.fromEntity(_soup),
    ];

    final result = await repository.getFavorites();

    expect((result as Success<List<MealSummary>>).value, [_stew, _soup]);
  });

  test('reads an empty store as an empty list', () async {
    final result = await repository.getFavorites();
    expect((result as Success<List<MealSummary>>).value, isEmpty);
  });

  test('saves the full list, replacing what was there', () async {
    await repository.saveFavorites([_soup]);
    final result = await repository.saveFavorites([_stew, _soup]);

    expect(result, isA<Success<void>>());
    expect(local.stored.map((m) => m.id), ['2', '1']);
  });

  test('reports a failed write as CacheFailure', () async {
    local.writeError = const CacheException('disk full');

    final result = await repository.saveFavorites([_soup]);

    expect((result as Failed<void>).failure, isA<CacheFailure>());
  });

  test('reports a failed read as CacheFailure', () async {
    local.readError = const CacheException('unreadable');

    final result = await repository.getFavorites();

    expect((result as Failed<List<MealSummary>>).failure, isA<CacheFailure>());
  });

  test(
    'turns any unexpected error into a failure instead of throwing',
    () async {
      local.readError = StateError('boom');
      local.writeError = StateError('boom');

      final read = await repository.getFavorites();
      final write = await repository.saveFavorites([_soup]);

      expect(
        (read as Failed<List<MealSummary>>).failure,
        isA<UnknownFailure>(),
      );
      expect((write as Failed<void>).failure, isA<UnknownFailure>());
    },
  );
}
