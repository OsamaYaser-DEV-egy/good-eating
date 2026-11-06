import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meal_details/presentation/cubit/meal_details_cubit.dart';
import 'package:good_eating/features/meals/domain/entities/meal_detail.dart';
import 'package:good_eating/features/meals/domain/usecases/get_meal_details.dart';

import '../../helpers/fake_meal_repository.dart';

void main() {
  late FakeMealRepository repository;

  setUp(() => repository = FakeMealRepository());

  MealDetailsCubit build({String mealId = 'Beef-1'}) => MealDetailsCubit(
    getMealDetails: GetMealDetails(repository),
    mealId: mealId,
  );

  test('starts with nothing loaded', () {
    expect(build().state, const DataInitial<MealDetail>());
  });

  blocTest<MealDetailsCubit, DataState<MealDetail>>(
    'loads the meal it was created for',
    build: () => build(mealId: 'Lamb-7'),
    act: (cubit) => cubit.load(),
    expect: () => [
      const DataLoading<MealDetail>(),
      DataSuccess(fakeMealDetail('Lamb-7')),
    ],
    verify: (_) => expect(repository.requestedDetails, ['Lamb-7']),
  );

  blocTest<MealDetailsCubit, DataState<MealDetail>>(
    'reports a failure',
    build: () {
      repository.detailsOverrides['Beef-1'] = const Failed(NetworkFailure());
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const DataLoading<MealDetail>(),
      const DataFailure<MealDetail>(NetworkFailure()),
    ],
  );

  blocTest<MealDetailsCubit, DataState<MealDetail>>(
    'reports a meal that does not exist as NotFoundFailure',
    build: () {
      repository.detailsOverrides['Beef-1'] = const Failed(NotFoundFailure());
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const DataLoading<MealDetail>(),
      const DataFailure<MealDetail>(NotFoundFailure()),
    ],
  );

  blocTest<MealDetailsCubit, DataState<MealDetail>>(
    'recovers when loaded again after a failure',
    build: () {
      repository.detailsOverrides['Beef-1'] = const Failed(TimeoutFailure());
      return build();
    },
    act: (cubit) async {
      await cubit.load();
      repository.detailsOverrides.remove('Beef-1');
      await cubit.load();
    },
    expect: () => [
      const DataLoading<MealDetail>(),
      const DataFailure<MealDetail>(TimeoutFailure()),
      const DataLoading<MealDetail>(),
      DataSuccess(fakeMealDetail('Beef-1')),
    ],
  );

  test('does not emit after being closed', () async {
    final held = repository.holdDetails('Beef-1');
    final cubit = build();

    final loading = cubit.load();
    await cubit.close();
    held.complete(Success(fakeMealDetail('Beef-1')));
    await loading;

    expect(cubit.state, const DataLoading<MealDetail>());
  });
}
