import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/utils/json_parsing.dart';
import 'package:good_eating/features/meals/data/models/meal_detail_model.dart';
import 'package:good_eating/features/meals/domain/entities/ingredient.dart';

import '../../../../helpers/fixture_reader.dart';

MealDetailModel _first(String fixture) => parseJsonList(
  readFixtureJson(fixture),
  'meals',
  MealDetailModel.fromJson,
).single;

void main() {
  group('MealDetailModel (real lookup.php response)', () {
    final meal = _first('lookup_52772.json').toEntity();

    test('maps the scalar fields', () {
      expect(meal.id, '52772');
      expect(meal.name, 'Teriyaki Chicken Casserole');
      expect(meal.category, 'Chicken');
      expect(meal.area, 'Japanese');
      expect(
        meal.thumbUrl,
        'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
      );
      expect(meal.youtubeUrl, 'https://www.youtube.com/watch?v=4aZr5hZXP_s');
    });

    test('reads a null source as null, not as an empty string', () {
      expect(meal.sourceUrl, isNull);
    });

    test('splits comma separated tags', () {
      expect(meal.tags, ['Meat', 'Casserole']);
    });

    test('flattens the 20 ingredient slots into the 9 that are filled', () {
      expect(meal.ingredients, hasLength(9));
      expect(
        meal.ingredients.first,
        const Ingredient(name: 'soy sauce', measure: '3/4 cup'),
      );
      expect(
        meal.ingredients.last,
        const Ingredient(name: 'brown rice', measure: '3 cups'),
      );
    });

    test('keeps ingredients in slot order with their own measures', () {
      expect(meal.ingredients.map((i) => i.name), [
        'soy sauce',
        'water',
        'brown sugar',
        'ground ginger',
        'minced garlic',
        'cornstarch',
        'chicken breasts',
        'stir-fry vegetables',
        'brown rice',
      ]);
      expect(meal.ingredients[7].measure, '1 (12 oz.)');
    });

    test('keeps the full instructions text', () {
      expect(meal.instructions, startsWith('Preheat oven'));
      expect(meal.instructions, contains('\n'));
    });

    test('parses a different real meal too', () {
      final penne = _first('search_arrabiata.json').toEntity();
      expect(penne.name, 'Spicy Arrabiata Penne');
      expect(penne.category, 'Vegetarian');
      expect(penne.area, 'Italian');
      expect(penne.tags, ['Pasta', 'Curry']);
      expect(penne.ingredients, isNotEmpty);
    });
  });

  group('MealDetailModel area fallback (real response)', () {
    test('uses strCountry when strArea is null', () {
      final meal = _first('lookup_53483_no_area.json').toEntity();
      expect(meal.area, 'Brazil');
    });
  });

  group('MealDetailModel (hostile input)', () {
    Map<String, dynamic> hostile({Map<String, dynamic> extra = const {}}) => {
      'idMeal': '1',
      'strMeal': 'Plain toast',
      'strCategory': null,
      'strArea': null,
      'strCountry': null,
      'strInstructions': null,
      'strMealThumb': null,
      'strTags': null,
      'strYoutube': null,
      'strSource': null,
      for (var i = 1; i <= 20; i++) ...{
        'strIngredient$i': null,
        'strMeasure$i': null,
      },
      ...extra,
    };

    test('rejects a meal with no id', () {
      expect(
        () => MealDetailModel.fromJson(hostile(extra: {'idMeal': null})),
        throwsA(isA<ParsingException>()),
      );
    });

    test('rejects a meal with a blank name', () {
      expect(
        () => MealDetailModel.fromJson(hostile(extra: {'strMeal': ' '})),
        throwsA(isA<ParsingException>()),
      );
    });

    test('accepts a meal that is null everywhere except id and name', () {
      final meal = MealDetailModel.fromJson(hostile()).toEntity();

      expect(meal.id, '1');
      expect(meal.name, 'Plain toast');
      expect(meal.category, isEmpty);
      expect(meal.area, isEmpty);
      expect(meal.instructions, isEmpty);
      expect(meal.thumbUrl, isEmpty);
      expect(meal.tags, isEmpty);
      expect(meal.ingredients, isEmpty);
      expect(meal.youtubeUrl, isNull);
      expect(meal.sourceUrl, isNull);
      expect(meal.instructionSteps, isEmpty);
    });

    test('treats a blank youtube link as no video', () {
      final meal = MealDetailModel.fromJson(
        hostile(extra: {'strYoutube': '  '}),
      ).toEntity();
      expect(meal.youtubeUrl, isNull);
    });

    test('skips ingredients that are null, empty or whitespace', () {
      final meal = MealDetailModel.fromJson(
        hostile(
          extra: {
            'strIngredient1': 'bread',
            'strMeasure1': '2 slices',
            'strIngredient2': '',
            'strMeasure2': '1 cup',
            'strIngredient3': '   ',
            'strIngredient4': null,
            'strIngredient5': 'butter',
            'strMeasure5': '1 tbsp',
          },
        ),
      ).toEntity();

      expect(meal.ingredients, const [
        Ingredient(name: 'bread', measure: '2 slices'),
        Ingredient(name: 'butter', measure: '1 tbsp'),
      ]);
    });

    test('keeps an ingredient whose measure is blank', () {
      final meal = MealDetailModel.fromJson(
        hostile(
          extra: {
            'strIngredient1': 'salt',
            'strMeasure1': ' ',
            'strIngredient2': 'pepper',
            'strMeasure2': null,
          },
        ),
      ).toEntity();

      expect(meal.ingredients, const [
        Ingredient(name: 'salt', measure: ''),
        Ingredient(name: 'pepper', measure: ''),
      ]);
    });

    test('reads ingredients that follow a gap in the numbering', () {
      final meal = MealDetailModel.fromJson(
        hostile(extra: {'strIngredient1': 'a', 'strIngredient20': 'z'}),
      ).toEntity();
      expect(meal.ingredients.map((i) => i.name), ['a', 'z']);
    });

    test('ignores ingredient slots beyond 20', () {
      final meal = MealDetailModel.fromJson(
        hostile(extra: {'strIngredient21': 'ghost'}),
      ).toEntity();
      expect(meal.ingredients, isEmpty);
    });

    test('drops blank entries from a messy tag list', () {
      final meal = MealDetailModel.fromJson(
        hostile(extra: {'strTags': ' Pasta, ,Curry,,'}),
      ).toEntity();
      expect(meal.tags, ['Pasta', 'Curry']);
    });

    test('prefers strArea over strCountry when both are present', () {
      final meal = MealDetailModel.fromJson(
        hostile(extra: {'strArea': 'Italian', 'strCountry': 'Italy'}),
      ).toEntity();
      expect(meal.area, 'Italian');
    });
  });
}
