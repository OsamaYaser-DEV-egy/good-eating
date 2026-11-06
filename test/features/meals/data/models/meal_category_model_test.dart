import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/utils/json_parsing.dart';
import 'package:good_eating/features/meals/data/models/meal_category_model.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';

import '../../../../helpers/fixture_reader.dart';

void main() {
  group('MealCategoryModel (real response)', () {
    final models = parseJsonList(
      readFixtureJson('categories.json'),
      'categories',
      MealCategoryModel.fromJson,
    );

    test('parses every category in the response', () {
      expect(models, hasLength(14));
      expect(models.map((m) => m.name), containsAll(['Beef', 'Seafood']));
    });

    test('maps all fields of the first category', () {
      final beef = models.first.toEntity();
      expect(beef.id, '1');
      expect(beef.name, 'Beef');
      expect(
        beef.thumbUrl,
        'https://www.themealdb.com/images/category/beef.png',
      );
      expect(beef.description, startsWith('Beef is the culinary name'));
    });

    test('gives every category a name, id and thumbnail', () {
      for (final model in models) {
        expect(model.id, isNotEmpty);
        expect(model.name, isNotEmpty);
        expect(model.thumbUrl, isNotEmpty);
      }
    });
  });

  group('MealCategoryModel (hostile input)', () {
    test('rejects a category with no id', () {
      expect(
        () => MealCategoryModel.fromJson({'strCategory': 'Beef'}),
        throwsA(isA<ParsingException>()),
      );
    });

    test('rejects a category whose name is blank', () {
      expect(
        () => MealCategoryModel.fromJson({
          'idCategory': '1',
          'strCategory': '   ',
        }),
        throwsA(isA<ParsingException>()),
      );
    });

    test('rejects an object where every field is null', () {
      expect(
        () => MealCategoryModel.fromJson({
          'idCategory': null,
          'strCategory': null,
          'strCategoryThumb': null,
          'strCategoryDescription': null,
        }),
        throwsA(isA<ParsingException>()),
      );
    });

    test('accepts a category with only an id and a name', () {
      final entity = MealCategoryModel.fromJson({
        'idCategory': 7,
        'strCategory': ' Beef ',
        'strCategoryThumb': null,
      }).toEntity();

      expect(
        entity,
        const MealCategory(
          id: '7',
          name: 'Beef',
          thumbUrl: '',
          description: '',
        ),
      );
    });
  });
}
