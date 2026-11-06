import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_cubit.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_state.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/domain/usecases/get_categories.dart';
import 'package:good_eating/features/meals/domain/usecases/get_meals_by_category.dart';

import '../../helpers/fake_meal_repository.dart';

CategoryMealsState _state(
  String? selected,
  DataState<List<MealSummary>> meals,
) => CategoryMealsState(selected: selected, meals: meals);

void main() {
  late FakeMealRepository repository;

  setUp(() => repository = FakeMealRepository());

  CategoryMealsCubit build() => CategoryMealsCubit(
    getCategories: GetCategories(repository),
    getMealsByCategory: GetMealsByCategory(repository),
  );

  List<MealSummary> meals(String category) => repository.defaultMeals(category);

  test('starts with no category chosen', () {
    expect(build().state, const CategoryMealsState.initial());
  });

  group('start', () {
    blocTest<CategoryMealsCubit, CategoryMealsState>(
      'opens the first category',
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => [
        _state(null, const DataLoading()),
        _state('Beef', const DataLoading()),
        _state('Beef', DataSuccess(meals('Beef'))),
      ],
    );

    blocTest<CategoryMealsCubit, CategoryMealsState>(
      'reports a failure to load the categories as the meals state',
      build: () {
        repository.categoriesResult = const Failed(NetworkFailure());
        return build();
      },
      act: (cubit) => cubit.start(),
      expect: () => [
        _state(null, const DataLoading()),
        _state(null, const DataFailure(NetworkFailure())),
      ],
      verify: (_) => expect(repository.requestedCategories, isEmpty),
    );

    blocTest<CategoryMealsCubit, CategoryMealsState>(
      'treats an empty category list as success with nothing to show',
      build: () {
        repository.categoriesResult = const Success([]);
        return build();
      },
      act: (cubit) => cubit.start(),
      expect: () => [
        _state(null, const DataLoading()),
        _state(null, const DataSuccess([])),
      ],
    );

    blocTest<CategoryMealsCubit, CategoryMealsState>(
      'after a failure it reloads the selected category, not the first',
      build: () {
        repository.mealsOverrides['Chicken'] = const Failed(TimeoutFailure());
        return build();
      },
      act: (cubit) async {
        await cubit.select('Chicken');
        repository.mealsOverrides.remove('Chicken');
        await cubit.start();
      },
      expect: () => [
        _state('Chicken', const DataLoading()),
        _state('Chicken', const DataFailure(TimeoutFailure())),
        _state('Chicken', const DataLoading()),
        _state('Chicken', DataSuccess(meals('Chicken'))),
      ],
      verify: (_) => expect(repository.categoriesCalls, 0),
    );
  });

  group('select', () {
    blocTest<CategoryMealsCubit, CategoryMealsState>(
      'highlights the category at once, then loads its meals',
      build: build,
      act: (cubit) => cubit.select('Dessert'),
      expect: () => [
        _state('Dessert', const DataLoading()),
        _state('Dessert', DataSuccess(meals('Dessert'))),
      ],
    );

    blocTest<CategoryMealsCubit, CategoryMealsState>(
      'reports a failed request against the selected category',
      build: () {
        repository.mealsOverrides['Lamb'] = const Failed(NetworkFailure());
        return build();
      },
      act: (cubit) => cubit.select('Lamb'),
      expect: () => [
        _state('Lamb', const DataLoading()),
        _state('Lamb', const DataFailure(NetworkFailure())),
      ],
    );

    blocTest<CategoryMealsCubit, CategoryMealsState>(
      'discards a slow answer for a category that is no longer selected',
      build: build,
      act: (cubit) async {
        final slowBeef = repository.holdMeals('Beef');

        final first = cubit.select('Beef');
        await cubit.select('Chicken');
        slowBeef.complete(Success(meals('Beef')));
        await first;
      },
      expect: () => [
        _state('Beef', const DataLoading()),
        _state('Chicken', const DataLoading()),
        _state('Chicken', DataSuccess(meals('Chicken'))),
      ],
      verify: (cubit) {
        expect(cubit.state.selected, 'Chicken');
        expect(cubit.state.meals, DataSuccess(meals('Chicken')));
      },
    );

    blocTest<CategoryMealsCubit, CategoryMealsState>(
      'keeps the newest selection when answers arrive in reverse order',
      build: build,
      act: (cubit) async {
        final slowBeef = repository.holdMeals('Beef');
        final slowChicken = repository.holdMeals('Chicken');

        final beef = cubit.select('Beef');
        final chicken = cubit.select('Chicken');
        slowChicken.complete(Success(meals('Chicken')));
        await chicken;
        slowBeef.complete(Success(meals('Beef')));
        await beef;
      },
      verify: (cubit) {
        expect(cubit.state.selected, 'Chicken');
        expect(cubit.state.meals, DataSuccess(meals('Chicken')));
      },
    );
  });

  test('does not emit after being closed', () async {
    final held = repository.holdMeals('Beef');
    final cubit = build();

    final loading = cubit.select('Beef');
    await cubit.close();
    held.complete(Success(meals('Beef')));
    await loading;

    expect(cubit.state.meals, const DataLoading<List<MealSummary>>());
  });
}
