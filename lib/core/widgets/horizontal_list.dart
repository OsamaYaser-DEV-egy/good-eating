import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_spacing.dart';

/// A fixed-height, horizontally scrolling list inset by the screen padding,
/// with the design's 16 px between items.
class HorizontalList extends StatelessWidget {
  const HorizontalList({
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = AppSpacing.lg,
    this.physics,
    super.key,
  });

  final double height;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double spacing;

  /// Pass `NeverScrollableScrollPhysics` for skeletons that should stay put.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: physics,
        padding: AppSpacing.screenPadding,
        itemCount: itemCount,
        separatorBuilder: (context, index) => SizedBox(width: spacing),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
