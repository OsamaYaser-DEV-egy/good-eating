import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/utils/ui_placeholders.dart';

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

    test('creators always come from the shared pool', () {
      final pool = UiPlaceholders.allCreators;
      for (final id in ids) {
        expect(pool, contains(UiPlaceholders.creator(id)));
      }
    });
  });
}
