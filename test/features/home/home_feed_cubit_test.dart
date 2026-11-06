import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/home/presentation/cubit/home_feed.dart';
import 'package:good_eating/features/home/presentation/cubit/home_feed_cubit.dart';
import 'package:good_eating/features/meals/domain/usecases/get_categories.dart';
import 'package:good_eating/features/meals/domain/usecases/get_meals_by_category.dart';

import '../../helpers/fake_meal_repository.dart';

void main() {
  late FakeMealRepository repository;

  setUp(() => repository = FakeMealRepository());

  HomeFeedCubit build() => HomeFeedCubit(
    getCategories: GetCategories(repository),
    getMealsByCategory: GetMealsByCategory(repository),
  );

  test('starts with nothing loaded', () {
    expect(build().state, const DataInitial<HomeFeed>());
  });

  blocTest<HomeFeedCubit, DataState<HomeFeed>>(
    'trending previews the second category and recent the third',
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const DataLoading<HomeFeed>(),
      DataSuccess(
        HomeFeed(
          trending: CategoryPreview(
            category: 'Chicken',
            meals: repository.defaultMeals('Chicken').take(5).toList(),
          ),
          recent: CategoryPreview(
            category: 'Dessert',
            meals: repository.defaultMeals('Dessert').take(5).toList(),
          ),
        ),
      ),
    ],
  );

  blocTest<HomeFeedCubit, DataState<HomeFeed>>(
    'never previews the first category, which the chips open on',
    build: build,
    act: (cubit) => cubit.load(),
    verify: (_) =>
        expect(repository.requestedCategories, isNot(contains('Beef'))),
  );

  test('caps each carousel at five meals', () async {
    repository = FakeMealRepository(mealsPerCategory: 12);
    final cubit = build();

    await cubit.load();

    final feed = (cubit.state as DataSuccess<HomeFeed>).data;
    expect(feed.trending.meals, hasLength(5));
    expect(feed.recent.meals, hasLength(5));
  });

  blocTest<HomeFeedCubit, DataState<HomeFeed>>(
    'fails when the categories cannot be loaded',
    build: () {
      repository.categoriesResult = const Failed(NetworkFailure());
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const DataLoading<HomeFeed>(),
      const DataFailure<HomeFeed>(NetworkFailure()),
    ],
    verify: (_) => expect(repository.requestedCategories, isEmpty),
  );

  blocTest<HomeFeedCubit, DataState<HomeFeed>>(
    'fails when the trending meals cannot be loaded',
    build: () {
      repository.mealsOverrides['Chicken'] = const Failed(TimeoutFailure());
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const DataLoading<HomeFeed>(),
      const DataFailure<HomeFeed>(TimeoutFailure()),
    ],
  );

  blocTest<HomeFeedCubit, DataState<HomeFeed>>(
    'fails when the recent meals cannot be loaded',
    build: () {
      repository.mealsOverrides['Dessert'] = const Failed(ServerFailure());
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const DataLoading<HomeFeed>(),
      const DataFailure<HomeFeed>(ServerFailure()),
    ],
  );

  blocTest<HomeFeedCubit, DataState<HomeFeed>>(
    'succeeds with empty carousels when there are no categories',
    build: () {
      repository.categoriesResult = const Success([]);
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const DataLoading<HomeFeed>(),
      const DataSuccess<HomeFeed>(HomeFeed.empty()),
    ],
  );

  test('wraps around when there are fewer than three categories', () async {
    repository = FakeMealRepository(categoryNames: ['Beef']);
    final cubit = build();

    await cubit.load();

    final feed = (cubit.state as DataSuccess<HomeFeed>).data;
    expect(feed.trending.category, 'Beef');
    expect(feed.recent.category, 'Beef');
  });

  blocTest<HomeFeedCubit, DataState<HomeFeed>>(
    'recovers when loaded again after a failure',
    build: () {
      repository.categoriesResult = const Failed(NetworkFailure());
      return build();
    },
    act: (cubit) async {
      await cubit.load();
      repository.categoriesResult = Success([
        for (final name in fakeCategoryNames) fakeCategory(name),
      ]);
      await cubit.load();
    },
    verify: (cubit) => expect(cubit.state, isA<DataSuccess<HomeFeed>>()),
  );
}
