import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';
import 'package:good_eating/features/meals/domain/usecases/get_categories.dart';
import 'package:good_eating/features/meals/presentation/cubit/categories_cubit.dart';

import '../../../helpers/fake_meal_repository.dart';

void main() {
  late FakeMealRepository repository;

  setUp(() => repository = FakeMealRepository());

  CategoriesCubit build() => CategoriesCubit(GetCategories(repository));

  test('starts with nothing loaded', () {
    expect(build().state, const DataInitial<List<MealCategory>>());
  });

  blocTest<CategoriesCubit, DataState<List<MealCategory>>>(
    'emits loading then the categories',
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const DataLoading<List<MealCategory>>(),
      DataSuccess([for (final name in fakeCategoryNames) fakeCategory(name)]),
    ],
  );

  blocTest<CategoriesCubit, DataState<List<MealCategory>>>(
    'emits loading then the failure',
    build: () {
      repository.categoriesResult = const Failed(NetworkFailure());
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const DataLoading<List<MealCategory>>(),
      const DataFailure<List<MealCategory>>(NetworkFailure()),
    ],
  );

  blocTest<CategoriesCubit, DataState<List<MealCategory>>>(
    'recovers when loaded again after a failure',
    build: () {
      repository.categoriesResult = const Failed(NetworkFailure());
      return build();
    },
    act: (cubit) async {
      await cubit.load();
      repository.categoriesResult = Success([fakeCategory('Beef')]);
      await cubit.load();
    },
    expect: () => [
      const DataLoading<List<MealCategory>>(),
      const DataFailure<List<MealCategory>>(NetworkFailure()),
      const DataLoading<List<MealCategory>>(),
      DataSuccess([fakeCategory('Beef')]),
    ],
  );

  test('does not emit after being closed', () async {
    final held = repository.holdCategories();
    final cubit = build();

    final loading = cubit.load();
    await cubit.close();
    held.complete(Success([fakeCategory('Beef')]));
    await loading;

    expect(cubit.state, const DataLoading<List<MealCategory>>());
  });
}
