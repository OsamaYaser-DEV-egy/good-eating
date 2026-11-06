import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/utils/ui_placeholders.dart';

import '../../helpers/fixture_reader.dart';

void main() {
  const ids = ['52772', '52959', '53013', '52874', '0', ''];

  group('UiPlaceholders', () {
    test('is deterministic for the same meal id', () {
      for (final id in ids) {
        expect(UiPlaceholders.rating(id), UiPlaceholders.rating(id));
        expect(UiPlaceholders.reviewCount(id), UiPlaceholders.reviewCount(id));
        expect(UiPlaceholders.cookMinutes(id), UiPlaceholders.cookMinutes(id));
        expect(UiPlaceholders.videoLength(id), UiPlaceholders.videoLength(id));
        expect(UiPlaceholders.creator(id), UiPlaceholders.creator(id));
      }
    });

    test('stays inside its documented ranges', () {
      for (final id in ids) {
        expect(UiPlaceholders.rating(id), inInclusiveRange(4.0, 5.0));
        expect(UiPlaceholders.reviewCount(id), inInclusiveRange(50, 500));
        expect(UiPlaceholders.cookMinutes(id), inInclusiveRange(10, 60));
        expect(UiPlaceholders.cookMinutes(id) % 5, 0);

        final video = UiPlaceholders.videoLength(id);
        expect(video.inSeconds, inInclusiveRange(5 * 60, 25 * 60 + 59));
      }
    });

    test('produces different values for different meals', () {
      final ratings = {for (final id in ids) UiPlaceholders.rating(id)};
      expect(ratings.length, greaterThan(1));
    });

    test('gives the values a reference FNV-1a implementation gives', () {
      // Computed independently with 64-bit integers. If these ever change, the
      // hash is no longer stable (for example because a 32-bit multiply
      // overflowed on the web), and a meal would show different numbers
      // depending on the platform.
      const expected = {
        '52772': (
          4.3,
          211,
          10,
          Duration(minutes: 21, seconds: 3),
          'Troyan Smith',
        ),
        '53120': (
          4.8,
          197,
          60,
          Duration(minutes: 23, seconds: 47),
          'Troyan Smith',
        ),
        '53138': (
          4.4,
          64,
          50,
          Duration(minutes: 24, seconds: 10),
          'James Wolden',
        ),
        '53111': (
          4.7,
          456,
          55,
          Duration(minutes: 13, seconds: 43),
          'Troyan Smith',
        ),
      };

      for (final MapEntry(key: id, value: want) in expected.entries) {
        expect(UiPlaceholders.rating(id), closeTo(want.$1, 1e-9), reason: id);
        expect(UiPlaceholders.reviewCount(id), want.$2, reason: id);
        expect(UiPlaceholders.cookMinutes(id), want.$3, reason: id);
        expect(UiPlaceholders.videoLength(id), want.$4, reason: id);
        expect(UiPlaceholders.creator(id).name, want.$5, reason: id);
      }
    });

    test('uses every creator across a real category of meal ids', () {
      final ids = [
        for (final meal
            in readFixtureJson('filter_seafood.json')['meals'] as List<dynamic>)
          (meal as Map<String, dynamic>)['idMeal'] as String,
      ];

      final counts = <String, int>{};
      for (final id in ids) {
        final name = UiPlaceholders.creator(id).name;
        counts[name] = (counts[name] ?? 0) + 1;
      }

      expect(counts.keys, hasLength(UiPlaceholders.allCreators.length));
      for (final count in counts.values) {
        expect(count, lessThan(ids.length ~/ 2), reason: 'skewed: $counts');
      }
    });

    test('every creator has an avatar asset', () {
      for (final creator in UiPlaceholders.allCreators) {
        expect(creator.avatarAsset, startsWith('assets/avatars/'));
        expect(creator.avatarAsset, endsWith('.png'));
      }
    });

    test('creators always come from the shared pool', () {
      const pool = UiPlaceholders.allCreators;
      for (final id in ids) {
        expect(pool, contains(UiPlaceholders.creator(id)));
      }
    });
  });
}
