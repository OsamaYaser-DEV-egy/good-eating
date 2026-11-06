import 'package:flutter_test/flutter_test.dart';
import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';
import 'package:good_eating/features/meals/domain/entities/meal_detail.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/domain/repositories/meal_repository.dart';
import 'package:good_eating/features/meals/domain/usecases/get_categories.dart';
import 'package:good_eating/features/meals/domain/usecases/get_meal_details.dart';
import 'package:good_eating/features/meals/domain/usecases/get_meals_by_category.dart';
import 'package:good_eating/features/meals/domain/usecases/search_meals.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements MealRepository {}

const _soup = MealSummary(id: '1', name: 'Soup', thumbUrl: 's.jpg');

void main() {
  late _MockRepository repository;

  setUp(() => repository = _MockRepository());

  test('GetCategories returns whatever the repository returns', () async {
    const categories = [
      MealCategory(id: '1', name: 'Beef', thumbUrl: '', description: ''),
    ];
    when(() => repository.getCategories())
        .thenAnswer((_) async => const Success(categories));

    final result = await GetCategories(repository)(const NoParams());

    expect((result as Success<List<MealCategory>>).value, categories);
  });

  test('GetMealsByCategory passes the category through', () async {
    when(() => repository.getMealsByCategory('Beef'))
        .thenAnswer((_) async => const Success([_soup]));

    final result = await GetMealsByCategory(repository)('Beef');

    expect((result as Success<List<MealSummary>>).value, const [_soup]);
    verify(() => repository.getMealsByCategory('Beef')).called(1);
  });

  test('GetMealDetails passes the id through and keeps a failure', () async {
    when(() => repository.getMealDetails('9'))
        .thenAnswer((_) async => const Failed<MealDetail>(NotFoundFailure()));

    final result = await GetMealDetails(repository)('9');

    expect((result as Failed<MealDetail>).failure, isA<NotFoundFailure>());
  });

  group('SearchMeals', () {
    test('trims the query before searching', () async {
      when(() => repository.searchMeals('soup'))
          .thenAnswer((_) async => const Success([_soup]));

      final result = await SearchMeals(repository)('  soup \n');

      expect((result as Success<List<MealSummary>>).value, const [_soup]);
      verify(() => repository.searchMeals('soup')).called(1);
    });

    test(
      'returns an empty success for blank text without any request',
      () async {
        final search = SearchMeals(repository);

        for (final blank in ['', '   ', '\t\n']) {
          final result = await search(blank);
          expect((result as Success<List<MealSummary>>).value, isEmpty);
        }

        verifyNever(() => repository.searchMeals(any()));
      },
    );
  });
}
