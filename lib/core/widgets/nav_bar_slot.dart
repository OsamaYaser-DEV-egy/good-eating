import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:good_eating/core/constants/app_durations.dart';
import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/widgets/nav_bar_item.dart';

/// A single tappable icon in the bottom navigation bar.
class NavBarSlot extends StatelessWidget {
  const NavBarSlot({
    required this.item,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final NavBarItem item;
  final bool selected;
  final VoidCallback onTap;

  static const double _selectedScale = 1.1;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedScale(
            scale: selected ? _selectedScale : 1,
            duration: AppDurations.fast,
            curve: Curves.easeOutBack,
            child: AnimatedSwitcher(
              duration: AppDurations.fast,
              child: _NavBarIcon(
                key: ValueKey(selected),
                item: item,
                selected: selected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  const _NavBarIcon({required this.item, required this.selected, super.key});

  final NavBarItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final activeAsset = item.activeIconAsset;
    if (!selected) return SvgPicture.asset(item.iconAsset);
    if (activeAsset != null) return SvgPicture.asset(activeAsset);
    return SvgPicture.asset(
      item.iconAsset,
      colorFilter: const ColorFilter.mode(AppColors.primary50, BlendMode.srcIn),
    );
  }
}
