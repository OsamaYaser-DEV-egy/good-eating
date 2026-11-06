import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/utils/json_parsing.dart';
import 'package:good_eating/features/meals/data/models/meal_detail_model.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

import '../../../helpers/fixture_reader.dart';

void main() {
  final meal = parseJsonList(
    readFixtureJson('lookup_52772.json'),
    'meals',
    MealDetailModel.fromJson,
  ).single.toEntity();

  test('toSummary keeps the id, name and image', () {
    expect(
      meal.toSummary(),
      const MealSummary(
        id: '52772',
        name: 'Teriyaki Chicken Casserole',
        thumbUrl:
            'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
      ),
    );
  });

  test('instructionSteps turns the real text into clean steps', () {
    final steps = meal.instructionSteps;

    expect(steps, hasLength(6));
    expect(steps.first, startsWith('Preheat oven'));
    expect(steps.last, startsWith('Add the cooked vegetables'));
    for (final step in steps) {
      expect(step, isNotEmpty);
      expect(step, isNot(contains('\r')));
      expect(step, isNot(contains('\n')));
    }
  });
}
