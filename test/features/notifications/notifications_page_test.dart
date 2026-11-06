import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/utils/ui_placeholders.dart';
import 'package:good_eating/features/meals/presentation/widgets/creator_line.dart';
import 'package:good_eating/features/notifications/presentation/notification_samples.dart';
import 'package:good_eating/features/notifications/presentation/widgets/notification_tile.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

Future<void> _openNotifications(
  WidgetTester tester, {
  double width = 375,
  double height = 2400,
}) async {
  await setUpDependencies();
  await pumpApp(tester, width: width, height: height);
  await tester.tap(find.bySemanticsLabel('Notifications'));
  await tester.pumpAndSettle();
}

void main() {
  group('the groups', () {
    testWidgets('show a heading, then Today and Yesterday', (tester) async {
      await _openNotifications(tester);

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
    });

    testWidgets('list Today before Yesterday', (tester) async {
      await _openNotifications(tester);

      expect(
        tester.getTopLeft(find.text('Today')).dy,
        lessThan(tester.getTopLeft(find.text('Yesterday')).dy),
      );
    });

    testWidgets('show every sample notification', (tester) async {
      await _openNotifications(tester);

      expect(
        find.byType(NotificationTile),
        findsNWidgets(
          NotificationSamples.today.length +
              NotificationSamples.yesterday.length,
        ),
      );
    });

    testWidgets('put each notification in its own group, in order', (
      tester,
    ) async {
      await _openNotifications(tester);

      final tiles = tester
          .widgetList<NotificationTile>(find.byType(NotificationTile))
          .map((tile) => tile.item)
          .toList();

      expect(tiles, [
        ...NotificationSamples.today,
        ...NotificationSamples.yesterday,
      ]);
      final yesterdayTop = tester.getTopLeft(find.text('Yesterday')).dy;
      final firstYesterday = tester
          .getTopLeft(
            find.byType(NotificationTile).at(NotificationSamples.today.length),
          )
          .dy;
      expect(firstYesterday, greaterThan(yesterdayTop));
    });
  });

  group('a notification', () {
    testWidgets('names who did it, what they did and when', (tester) async {
      await _openNotifications(tester);

      expect(
        find.textContaining('started following you', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('2 min ago'), findsOneWidget);
      expect(find.byType(CreatorAvatar), findsWidgets);
    });

    testWidgets('uses the creators the rest of the app uses', (tester) async {
      await _openNotifications(tester);

      final names = {for (final c in UiPlaceholders.allCreators) c.name};
      for (final item in [
        ...NotificationSamples.today,
        ...NotificationSamples.yesterday,
      ]) {
        expect(names, contains(item.creator.name));
      }
    });

    testWidgets('marks only the unread ones', (tester) async {
      await _openNotifications(tester);

      final unread = NotificationSamples.today
          .followedBy(NotificationSamples.yesterday)
          .where((item) => item.isUnread)
          .length;

      expect(
        find.bySemanticsLabel(RegExp(r', unread$')),
        findsNWidgets(unread),
      );
      expect(unread, greaterThan(0));
      expect(
        unread,
        lessThan(
          NotificationSamples.today.length +
              NotificationSamples.yesterday.length,
        ),
        reason: 'the samples should show both read and unread',
      );
    });

    testWidgets('reads as one item to a screen reader', (tester) async {
      await _openNotifications(tester);

      expect(
        find.bySemanticsLabel(
          'Niki Samantha started following you, 2 min ago, unread',
        ),
        findsOneWidget,
      );
    });
  });

  group('layout', () {
    for (final width in [320.0, 375.0, 430.0]) {
      final label = width.toInt();

      testWidgets('has no overflow at $label wide', (tester) async {
        await _openNotifications(tester, width: width);
        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, scrolled to the end', (
        tester,
      ) async {
        await _openNotifications(tester, width: width, height: 480);

        await tester.drag(find.byType(ListView).last, const Offset(0, -20000));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('keeps the last notification clear of the navigation bar', (
      tester,
    ) async {
      await _openNotifications(tester, height: 480);

      await tester.drag(find.byType(ListView).last, const Offset(0, -20000));
      await tester.pumpAndSettle();

      final last = tester.getRect(find.byType(NotificationTile).last);
      expect(last.bottom, lessThanOrEqualTo(480 - 86));
    });
  });
}
