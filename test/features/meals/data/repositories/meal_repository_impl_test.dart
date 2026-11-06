import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/data/datasources/meal_remote_data_source.dart';
import 'package:good_eating/features/meals/data/models/meal_category_model.dart';
import 'package:good_eating/features/meals/data/models/meal_detail_model.dart';
import 'package:good_eating/features/meals/data/models/meal_summary_model.dart';
import 'package:good_eating/features/meals/data/repositories/meal_repository_impl.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';
import 'package:good_eating/features/meals/domain/entities/meal_detail.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements MealRemoteDataSource {}

DioException _dioError(DioExceptionType type, {int? statusCode}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: type,
    response: statusCode == null
        ? null
        : Response<Object?>(requestOptions: options, statusCode: statusCode),
  );
}

const _beefModel = MealCategoryModel(
  id: '1',
  name: 'Beef',
  thumbUrl: 'beef.png',
  description: 'Meat',
);
const _soupModel = MealSummaryModel(id: '10', name: 'Soup', thumbUrl: 's.jpg');
const _detailModel = MealDetailModel(
  id: '10',
  name: 'Soup',
  category: 'Starter',
  area: 'French',
  instructions: 'Heat.',
  thumbUrl: 's.jpg',
  ingredients: [],
  tags: [],
);

void main() {
  late _MockRemote remote;
  late MealRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = MealRepositoryImpl(remote);
  });

  group('getCategories', () {
    test('maps models to entities', () async {
      when(() => remote.getCategories()).thenAnswer((_) async => [_beefModel]);

      final result = await repository.getCategories();

      expect((result as Success<List<MealCategory>>).value, const [
        MealCategory(
          id: '1',
          name: 'Beef',
          thumbUrl: 'beef.png',
          description: 'Meat',
        ),
      ]);
    });

    test('asks the server only once and then answers from memory', () async {
      when(() => remote.getCategories()).thenAnswer((_) async => [_beefModel]);

      await repository.getCategories();
      await repository.getCategories();
      await repository.getCategories();

      verify(() => remote.getCategories()).called(1);
    });

    test(
      'does not cache a failure, so retrying asks the server again',
      () async {
        var calls = 0;
        when(() => remote.getCategories()).thenAnswer((_) async {
          calls++;
          if (calls == 1) throw _dioError(DioExceptionType.connectionError);
          return [_beefModel];
        });

        final first = await repository.getCategories();
        final second = await repository.getCategories();

        expect(
          (first as Failed<List<MealCategory>>).failure,
          isA<NetworkFailure>(),
        );
        expect(second, isA<Success<List<MealCategory>>>());
        verify(() => remote.getCategories()).called(2);
      },
    );
  });

  group('getMealsByCategory', () {
    test('maps models to entities', () async {
      when(() => remote.getMealsByCategory('Starter'))
          .thenAnswer((_) async => [_soupModel]);

      final result = await repository.getMealsByCategory('Starter');

      expect((result as Success<List<MealSummary>>).value, const [
        MealSummary(id: '10', name: 'Soup', thumbUrl: 's.jpg'),
      ]);
    });

    test('caches each category separately', () async {
      when(() => remote.getMealsByCategory(any()))
          .thenAnswer((_) async => [_soupModel]);

      await repository.getMealsByCategory('Starter');
      await repository.getMealsByCategory('Starter');
      await repository.getMealsByCategory('Side');

      verify(() => remote.getMealsByCategory('Starter')).called(1);
      verify(() => remote.getMealsByCategory('Side')).called(1);
    });

    test('caches an empty category so it is not refetched', () async {
      when(() => remote.getMealsByCategory('Goat'))
          .thenAnswer((_) async => const []);

      await repository.getMealsByCategory('Goat');
      final again = await repository.getMealsByCategory('Goat');

      expect((again as Success<List<MealSummary>>).value, isEmpty);
      verify(() => remote.getMealsByCategory('Goat')).called(1);
    });

    test('reports a timeout as TimeoutFailure', () async {
      when(() => remote.getMealsByCategory('Beef'))
          .thenThrow(_dioError(DioExceptionType.receiveTimeout));

      final result = await repository.getMealsByCategory('Beef');

      expect(
        (result as Failed<List<MealSummary>>).failure,
        isA<TimeoutFailure>(),
      );
    });

    test('reports a 500 as ServerFailure with its status code', () async {
      when(() => remote.getMealsByCategory('Beef'))
          .thenThrow(_dioError(DioExceptionType.badResponse, statusCode: 503));

      final failure = ((await repository.getMealsByCategory(
        'Beef',
      )) as Failed<List<MealSummary>>).failure;

      expect(failure, const ServerFailure(statusCode: 503));
    });
  });

  group('getMealDetails', () {
    test('maps the model to an entity', () async {
      when(() => remote.getMealDetails('10'))
          .thenAnswer((_) async => _detailModel);

      final result = await repository.getMealDetails('10');

      expect(
        (result as Success<MealDetail>).value,
        const MealDetail(
          id: '10',
          name: 'Soup',
          category: 'Starter',
          area: 'French',
          instructions: 'Heat.',
          thumbUrl: 's.jpg',
          ingredients: [],
        ),
      );
    });

    test('caches a found meal by id', () async {
      when(() => remote.getMealDetails('10'))
          .thenAnswer((_) async => _detailModel);

      await repository.getMealDetails('10');
      await repository.getMealDetails('10');

      verify(() => remote.getMealDetails('10')).called(1);
    });

    test('returns NotFoundFailure when the API has no such meal', () async {
      when(() => remote.getMealDetails('0')).thenAnswer((_) async => null);

      final result = await repository.getMealDetails('0');

      expect(result, isA<Failed<MealDetail>>());
      expect((result as Failed<MealDetail>).failure, isA<NotFoundFailure>());
    });

    test('does not cache a not-found result', () async {
      when(() => remote.getMealDetails('0')).thenAnswer((_) async => null);

      await repository.getMealDetails('0');
      await repository.getMealDetails('0');

      verify(() => remote.getMealDetails('0')).called(2);
    });

    test('maps malformed data to ParsingFailure', () async {
      when(() => remote.getMealDetails('10'))
          .thenThrow(const ParsingException('bad shape'));

      final result = await repository.getMealDetails('10');

      expect((result as Failed<MealDetail>).failure, isA<ParsingFailure>());
    });
  });

  group('searchMeals', () {
    test('returns the matches as summaries', () async {
      when(() => remote.searchMeals('soup'))
          .thenAnswer((_) async => [_soupModel]);

      final result = await repository.searchMeals('soup');

      expect((result as Success<List<MealSummary>>).value.single.name, 'Soup');
    });

    test('treats no matches as success with an empty list', () async {
      when(() => remote.searchMeals('zzz')).thenAnswer((_) async => const []);

      final result = await repository.searchMeals('zzz');

      expect((result as Success<List<MealSummary>>).value, isEmpty);
    });

    test('is not cached, because every query is different', () async {
      when(() => remote.searchMeals('soup'))
          .thenAnswer((_) async => [_soupModel]);

      await repository.searchMeals('soup');
      await repository.searchMeals('soup');

      verify(() => remote.searchMeals('soup')).called(2);
    });

    test('reports a lost connection as NetworkFailure', () async {
      when(() => remote.searchMeals('soup'))
          .thenThrow(_dioError(DioExceptionType.connectionError));

      final result = await repository.searchMeals('soup');

      expect(
        (result as Failed<List<MealSummary>>).failure,
        isA<NetworkFailure>(),
      );
    });
  });
}
