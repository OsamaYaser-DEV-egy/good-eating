import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/utils/formatters.dart';

void main() {
  group('Formatters.rating', () {
    test('uses a decimal comma, as the design does', () {
      expect(Formatters.rating(4.5), '4,5');
      expect(Formatters.rating(5), '5,0');
    });

    test('rounds to one decimal', () {
      expect(Formatters.rating(4.26), '4,3');
      expect(Formatters.rating(4.04), '4,0');
    });
  });

  group('Formatters.videoLength', () {
    test('pads the seconds but not the minutes', () {
      expect(
        Formatters.videoLength(const Duration(minutes: 5, seconds: 7)),
        '5:07',
      );
      expect(
        Formatters.videoLength(const Duration(minutes: 15, seconds: 10)),
        '15:10',
      );
    });

    test('shows whole minutes as m:00', () {
      expect(Formatters.videoLength(const Duration(minutes: 12)), '12:00');
    });

    test('carries minutes past an hour instead of wrapping', () {
      expect(
        Formatters.videoLength(const Duration(hours: 1, minutes: 5)),
        '65:00',
      );
    });
  });

  test('Formatters.cookTime appends Mins', () {
    expect(Formatters.cookTime(10), '10 Mins');
    expect(Formatters.cookTime(45), '45 Mins');
  });

  group('Formatters.itemCount', () {
    test(
      'is singular for one',
      () => expect(Formatters.itemCount(1), '1 item'),
    );

    test('is plural for everything else, including zero', () {
      expect(Formatters.itemCount(0), '0 items');
      expect(Formatters.itemCount(5), '5 items');
      expect(Formatters.itemCount(20), '20 items');
    });
  });

  group('Formatters.reviewCount', () {
    test('wraps the count in brackets', () {
      expect(Formatters.reviewCount(300), '(300 Reviews)');
    });

    test('is singular for one', () {
      expect(Formatters.reviewCount(1), '(1 Review)');
    });
  });
}
