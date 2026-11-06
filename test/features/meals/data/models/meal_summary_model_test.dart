import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/utils/json_parsing.dart';
import 'package:good_eating/features/meals/data/models/meal_summary_model.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

import '../../../../helpers/fixture_reader.dart';

void main() {
  group('MealSummaryModel (real filter.php response)', () {
    final models = parseJsonList(
      readFixtureJson('filter_seafood.json'),
      'meals',
      MealSummaryModel.fromJson,
    );

    test('parses all 84 meals, ignoring the extra area and country keys', () {
      expect(models, hasLength(84));
    });

    test('maps the first meal', () {
      expect(
        models.first.toEntity(),
        const MealSummary(
          id: '53483',
          name: 'Acaraje black-eyed pea fritters with shrimp filling',
          thumbUrl: 'https://www.themealdb.com/images/media/meals/dxs5t71782678369.jpg',
        ),
      );
    });

    test('gives every meal an id, name and image', () {
      for (final model in models) {
        expect(model.id, isNotEmpty);
        expect(model.name, isNotEmpty);
        expect(model.thumbUrl, isNotEmpty);
      }
    });

    test('has no duplicate ids', () {
      expect(models.map((m) => m.id).toSet(), hasLength(models.length));
    });
  });

  group('MealSummaryModel (real search.php response)', () {
    test('reads the summary out of a full meal object', () {
      final models = parseJsonList(
        readFixtureJson('search_arrabiata.json'),
        'meals',
        MealSummaryModel.fromJson,
      );

      expect(models, hasLength(1));
      expect(models.single.id, '52771');
      expect(models.single.name, 'Spicy Arrabiata Penne');
    });
  });

  group('MealSummaryModel (hostile input)', () {
    test('rejects a meal with no id', () {
      expect(
        () => MealSummaryModel.fromJson({'strMeal': 'Soup'}),
        throwsA(isA<ParsingException>()),
      );
    });

    test('rejects a meal with no name', () {
      expect(
        () => MealSummaryModel.fromJson({'idMeal': '1', 'strMeal': null}),
        throwsA(isA<ParsingException>()),
      );
    });

    test('falls back to an empty thumbnail when the image is null', () {
      final entity = MealSummaryModel.fromJson({
        'idMeal': '1',
        'strMeal': 'Soup',
        'strMealThumb': null,
      }).toEntity();
      expect(entity.thumbUrl, isEmpty);
    });

    test('drops only the broken entries of a mixed list', () {
      final models = parseJsonList(
        {
          'meals': [
            {'idMeal': null, 'strMeal': null, 'strMealThumb': null},
            {'idMeal': '2', 'strMeal': 'Stew', 'strMealThumb': 'x.jpg'},
            {'idMeal': '3', 'strMeal': '', 'strMealThumb': 'y.jpg'},
          ],
        },
        'meals',
        MealSummaryModel.fromJson,
      );
      expect(models.map((m) => m.id), ['2']);
    });
  });
}
