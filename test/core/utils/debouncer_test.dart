import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/utils/debouncer.dart';

void main() {
  const wait = Duration(milliseconds: 300);

  test('runs only the last action after calls stop', () {
    fakeAsync((async) {
      final debouncer = Debouncer(duration: wait);
      final calls = <String>[];

      debouncer.run(() => calls.add('a'));
      async.elapse(const Duration(milliseconds: 100));
      debouncer.run(() => calls.add('b'));
      async.elapse(const Duration(milliseconds: 100));
      debouncer.run(() => calls.add('c'));

      async.elapse(const Duration(milliseconds: 299));
      expect(calls, isEmpty);

      async.elapse(const Duration(milliseconds: 1));
      expect(calls, ['c']);
    });
  });

  test('cancel drops the pending action', () {
    fakeAsync((async) {
      final debouncer = Debouncer(duration: wait);
      var ran = false;

      debouncer.run(() => ran = true);
      debouncer.cancel();
      async.elapse(wait * 2);

      expect(ran, isFalse);
    });
  });
}
