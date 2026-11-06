import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/widgets/bottom_nav_bar_painter.dart';
import 'package:good_eating/core/widgets/nav_bar_center_button.dart';
import 'package:good_eating/core/widgets/nav_bar_item.dart';
import 'package:good_eating/core/widgets/nav_bar_slot.dart';

/// The notched bottom navigation bar from the Figma `Nav Bar` component.
///
/// Four icon slots sit either side of a floating centre button. Pass
/// `selectedIndex: null` when the centre button's destination is active so no
/// icon is highlighted.
///
/// The bar reserves space for the system gesture area, so give the [Scaffold]
/// `extendBody: true` and pad scrolling content by this widget's height.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onItemTap,
    required this.centerIconAsset,
    required this.centerSemanticLabel,
    required this.onCenterTap,
    super.key,
  }) : assert(items.length == 4, 'The bar has exactly four icon slots.');

  final List<NavBarItem> items;
  final int? selectedIndex;
  final ValueChanged<int> onItemTap;
  final String centerIconAsset;
  final String centerSemanticLabel;
  final VoidCallback onCenterTap;

  /// How far the centre button rises above the bar's top edge.
  static const double overhang = 14;

  /// Bar height above the system gesture inset.
  static const double _barContentHeight = 72;

  /// Icon slots are 40 high in the design; the row is padded to a 56 touch
  /// target and centred on the same line.
  static const double _slotRowTop = overhang + 8;
  static const double _slotRowHeight = 56;

  /// Horizontal space reserved for the notch between the two slot groups.
  static const double _centerGap = 79;

  /// The bar's total height including the system gesture inset. Scrolling
  /// screens pad their bottom by this much so content is never hidden.
  static double heightOf(BuildContext context) =>
      overhang + _barContentHeight + MediaQuery.paddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    final barHeight = heightOf(context) - overhang;

    final slots = [
      for (var i = 0; i < items.length; i++)
        Expanded(
          child: NavBarSlot(
            item: items[i],
            selected: selectedIndex == i,
            onTap: () => onItemTap(i),
          ),
        ),
    ];

    return SizedBox(
      height: overhang + barHeight,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: overhang,
            height: barHeight,
            child: const CustomPaint(painter: BottomNavBarPainter()),
          ),
          Positioned(
            left: AppSpacing.screenHorizontal,
            right: AppSpacing.screenHorizontal,
            top: _slotRowTop,
            height: _slotRowHeight,
            child: Row(
              children: [
                ...slots.take(2),
                const SizedBox(width: _centerGap),
                ...slots.skip(2),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Center(
              child: NavBarCenterButton(
                iconAsset: centerIconAsset,
                semanticLabel: centerSemanticLabel,
                onTap: onCenterTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
