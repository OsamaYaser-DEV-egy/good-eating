import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/constants/app_assets.dart';
import 'package:good_eating/core/widgets/app_bottom_nav_bar.dart';
import 'package:good_eating/core/widgets/nav_bar_item.dart';

const _items = [
  NavBarItem(
    iconAsset: AppAssets.navHome,
    activeIconAsset: AppAssets.navHomeActive,
    semanticLabel: 'Home',
  ),
  NavBarItem(iconAsset: AppAssets.navSaved, semanticLabel: 'Saved'),
  NavBarItem(
    iconAsset: AppAssets.navNotifications,
    semanticLabel: 'Notifications',
  ),
  NavBarItem(iconAsset: AppAssets.navProfile, semanticLabel: 'Profile'),
];

Widget _bar({
  int? selectedIndex = 0,
  ValueChanged<int>? onItemTap,
  VoidCallback? onCenterTap,
}) {
  return MaterialApp(
    home: Scaffold(
      bottomNavigationBar: AppBottomNavBar(
        items: _items,
        selectedIndex: selectedIndex,
        onItemTap: onItemTap ?? (_) {},
        centerIconAsset: AppAssets.search,
        centerSemanticLabel: 'Search',
        onCenterTap: onCenterTap ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('reports which slot was tapped', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(_bar(onItemTap: taps.add));

    await tester.tap(find.bySemanticsLabel('Saved'));
    await tester.tap(find.bySemanticsLabel('Profile'));

    expect(taps, [1, 3]);
  });

  testWidgets('centre button fires its own callback', (tester) async {
    var centerTaps = 0;
    final slotTaps = <int>[];
    await tester.pumpWidget(
      _bar(onItemTap: slotTaps.add, onCenterTap: () => centerTaps++),
    );

    await tester.tap(find.bySemanticsLabel('Search'));

    expect(centerTaps, 1);
    expect(slotTaps, isEmpty);
  });

  testWidgets('marks only the selected slot as selected', (tester) async {
    await tester.pumpWidget(_bar(selectedIndex: 2));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Notifications')),
      isSemantics(isSelected: true),
    );
    for (final label in ['Home', 'Saved', 'Profile']) {
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        isNot(isSemantics(isSelected: true)),
      );
    }
  });

  testWidgets('highlights nothing when selectedIndex is null', (tester) async {
    await tester.pumpWidget(_bar(selectedIndex: null));

    for (final label in ['Home', 'Saved', 'Notifications', 'Profile']) {
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        isNot(isSemantics(isSelected: true)),
      );
    }
  });

  testWidgets('does not overflow on a narrow 320 wide screen', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_bar());

    expect(tester.takeException(), isNull);
  });
}
