// Hits the real TheMealDB API to prove the models cope with live data.
//
// Skipped by default so the normal suite stays offline and deterministic.
// Run it on demand:
//
//   PowerShell:  $env:LIVE_API = '1'; flutter test test/live
//   bash:        LIVE_API=1 flutter test test/live
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/network/api_client.dart';
import 'package:good_eating/core/network/dio_factory.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/data/datasources/meal_remote_data_source.dart';
import 'package:good_eating/features/meals/data/repositories/meal_repository_impl.dart';
import 'package:good_eating/features/meals/domain/entities/meal_detail.dart';

T _value<T>(Result<T> result) => switch (result) {
  Success(:final value) => value,
  Failed(:final failure) => fail('Expected success but got $failure'),
};

void main() {
  final enabled = Platform.environment['LIVE_API'] == '1';
  final skip = enabled ? false : 'Set LIVE_API=1 to run against the real API.';

  // `flutter_test` replaces the HTTP client with one that answers every request
  // with 400, so it would never reach the real server. Restore the real one.
  setUpAll(() => HttpOverrides.global = null);

  late MealRepositoryImpl repository;

  setUp(() {
    final dio = DioFactory.create(enableLogging: false);
    repository = MealRepositoryImpl(MealRemoteDataSourceImpl(ApiClient(dio)));
  });

  test('categories load and include Beef', () async {
    final categories = _value(await repository.getCategories());

    expect(categories.length, greaterThanOrEqualTo(10));
    expect(categories.map((c) => c.name), contains('Beef'));
  }, skip: skip);

  test(
    'the first meal of every category loads in full',
    () async {
      final categories = _value(await repository.getCategories());

      for (final category in categories) {
        final meals = _value(
          await repository.getMealsByCategory(category.name),
        );
        expect(meals, isNotEmpty, reason: '${category.name} has no meals');

        final detail = _value(await repository.getMealDetails(meals.first.id));
        expect(detail.id, meals.first.id);
        expect(detail.name, isNotEmpty);
        expect(
          detail.ingredients,
          isNotEmpty,
          reason: '${detail.name} (${category.name}) has no ingredients',
        );
        expect(detail.instructionSteps, isNotEmpty);
      }
    },
    skip: skip,
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test('searching a known meal finds it', () async {
    final results = _value(await repository.searchMeals('Arrabiata'));
    expect(results.map((m) => m.name), contains('Spicy Arrabiata Penne'));
  }, skip: skip);

  test('a search with no matches is an empty success, not an error', () async {
    final results = _value(await repository.searchMeals('zzzzqqqq'));
    expect(results, isEmpty);
  }, skip: skip);

  test('an unknown meal id is a NotFoundFailure', () async {
    final result = await repository.getMealDetails('0');

    expect(result, isA<Failed<MealDetail>>());
    expect((result as Failed<MealDetail>).failure, isA<NotFoundFailure>());
  }, skip: skip);
}
