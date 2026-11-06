import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/constants/app_assets.dart';
import 'package:good_eating/core/widgets/app_bottom_nav_bar.dart';
import 'package:good_eating/core/widgets/nav_bar_item.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_cubit.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_tab.dart';

/// Connects [AppBottomNavBar] to [ShellCubit].
class ShellBottomBar extends StatelessWidget {
  const ShellBottomBar({super.key});

  /// The tabs behind the four icon slots, left to right.
  static const List<ShellTab> _slotTabs = [
    ShellTab.home,
    ShellTab.saved,
    ShellTab.notifications,
    ShellTab.profile,
  ];

  static const List<NavBarItem> _items = [
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ShellCubit>();

    return BlocBuilder<ShellCubit, ShellTab>(
      builder: (context, tab) {
        final slot = _slotTabs.indexOf(tab);
        return AppBottomNavBar(
          items: _items,
          selectedIndex: slot == -1 ? null : slot,
          onItemTap: (index) => cubit.select(_slotTabs[index]),
          centerIconAsset: AppAssets.search,
          centerSemanticLabel: 'Search',
          onCenterTap: () => cubit.select(ShellTab.search),
        );
      },
    );
  }
}
