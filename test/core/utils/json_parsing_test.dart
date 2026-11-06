import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/utils/json_parsing.dart';

String _requireName(Map<String, dynamic> json) {
  final name = readString(json, 'name');
  if (name == null) throw const ParsingException('no name');
  return name;
}

void main() {
  group('readString', () {
    test('returns null for a missing key', () {
      expect(readString(<String, dynamic>{}, 'a'), isNull);
    });

    test('returns null for null, empty and whitespace-only values', () {
      expect(readString({'a': null}, 'a'), isNull);
      expect(readString({'a': ''}, 'a'), isNull);
      expect(readString({'a': '   '}, 'a'), isNull);
      expect(readString({'a': '\r\n'}, 'a'), isNull);
    });

    test('trims surrounding whitespace', () {
      expect(readString({'a': '  soy sauce \n'}, 'a'), 'soy sauce');
    });

    test('accepts numbers where the API sometimes sends ids', () {
      expect(readString({'a': 52772}, 'a'), '52772');
    });
  });

  group('parseJsonList', () {
    test('returns an empty list for a null value (the "no results" reply)', () {
      expect(parseJsonList({'meals': null}, 'meals', _requireName), isEmpty);
    });

    test('returns an empty list when the key is missing', () {
      expect(
        parseJsonList(<String, dynamic>{}, 'meals', _requireName),
        isEmpty,
      );
    });

    test('returns an empty list for a placeholder string', () {
      expect(
        parseJsonList({'meals': 'no data found'}, 'meals', _requireName),
        isEmpty,
      );
    });

    test('decodes every valid entry in order', () {
      final names = parseJsonList(
        {
          'meals': [
            {'name': 'a'},
            {'name': 'b'},
          ],
        },
        'meals',
        _requireName,
      );
      expect(names, ['a', 'b']);
    });

    test('skips entries that are not objects', () {
      final names = parseJsonList(
        {
          'meals': [
            null,
            'text',
            42,
            {'name': 'kept'},
          ],
        },
        'meals',
        _requireName,
      );
      expect(names, ['kept']);
    });

    test('skips entries rejected with a ParsingException', () {
      final names = parseJsonList(
        {
          'meals': [
            {'name': null},
            {'name': 'kept'},
            {'name': ''},
          ],
        },
        'meals',
        _requireName,
      );
      expect(names, ['kept']);
    });

    test('lets any other error escape rather than hiding a real bug', () {
      expect(
        () => parseJsonList(
          {
            'meals': [
              {'name': 'x'},
            ],
          },
          'meals',
          (_) => throw StateError('bug'),
        ),
        throwsStateError,
      );
    });
  });
}
