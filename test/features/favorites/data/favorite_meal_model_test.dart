import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/features/favorites/data/models/favorite_meal_model.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

void main() {
  const meal = MealSummary(
    id: '52772',
    name: 'Teriyaki Chicken Casserole',
    thumbUrl:
        'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
  );

  test('survives a trip through JSON unchanged', () {
    final model = FavoriteMealModel.fromEntity(meal);
    final restored = FavoriteMealModel.fromJson(model.toJson());

    expect(restored.toEntity(), meal);
  });

  test('stores under its own keys, not the API field names', () {
    expect(FavoriteMealModel.fromEntity(meal).toJson(), {
      'id': '52772',
      'name': 'Teriyaki Chicken Casserole',
      'thumbUrl':
          'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
    });
  });

  test('reads a numeric id as text', () {
    final model = FavoriteMealModel.fromJson({'id': 52772, 'name': 'Soup'});
    expect(model.id, '52772');
  });

  test('falls back to an empty photo when the url is missing or blank', () {
    expect(
      FavoriteMealModel.fromJson({'id': '1', 'name': 'Soup'}).thumbUrl,
      '',
    );
    expect(
      FavoriteMealModel.fromJson({'id': '1', 'name': 'Soup', 'thumbUrl': '   '})
          .thumbUrl,
      '',
    );
  });

  test('rejects a record with no id', () {
    expect(
      () => FavoriteMealModel.fromJson({'name': 'Soup'}),
      throwsA(isA<ParsingException>()),
    );
  });

  test('rejects a record with a blank name', () {
    expect(
      () => FavoriteMealModel.fromJson({'id': '1', 'name': '  '}),
      throwsA(isA<ParsingException>()),
    );
  });

  test('rejects a record where every field is null', () {
    expect(
      () => FavoriteMealModel.fromJson({
        'id': null,
        'name': null,
        'thumbUrl': null,
      }),
      throwsA(isA<ParsingException>()),
    );
  });
}
