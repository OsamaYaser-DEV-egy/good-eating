import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/constants/api_constants.dart';

void main() {
  group('ApiConstants.ingredientImageUrl', () {
    test('builds the small PNG url', () {
      expect(
        ApiConstants.ingredientImageUrl('Chicken'),
        'https://www.themealdb.com/images/ingredients/Chicken-Small.png',
      );
    });

    test('percent-encodes spaces, which the CDN requires', () {
      expect(
        ApiConstants.ingredientImageUrl('soy sauce'),
        'https://www.themealdb.com/images/ingredients/soy%20sauce-Small.png',
      );
    });

    test('keeps hyphens and encodes slashes and ampersands', () {
      expect(
        ApiConstants.ingredientImageUrl('stir-fry vegetables'),
        contains('stir-fry%20vegetables'),
      );
      expect(ApiConstants.ingredientImageUrl('a/b&c'), contains('a%2Fb%26c'));
    });
  });
}
