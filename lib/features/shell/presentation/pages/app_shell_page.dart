import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/features/favorites/presentation/pages/favorites_page.dart';
import 'package:good_eating/features/home/presentation/pages/home_page.dart';
import 'package:good_eating/features/notifications/presentation/pages/notifications_page.dart';
import 'package:good_eating/features/profile/presentation/pages/profile_page.dart';
import 'package:good_eating/features/search/presentation/pages/search_page.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_cubit.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_tab.dart';
import 'package:good_eating/features/shell/presentation/widgets/shell_bottom_bar.dart';

/// Root screen: the five tabs behind the custom bottom navigation bar.
///
/// An [IndexedStack] keeps every tab alive, so each one preserves its scroll
/// position and loaded data while another is showing.
class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key});

  /// Order must match [ShellTab.values].
  static const List<Widget> _tabs = [
    HomePage(),
    FavoritesPage(),
    SearchPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: BlocBuilder<ShellCubit, ShellTab>(
        builder: (context, tab) =>
            IndexedStack(index: tab.index, children: _tabs),
      ),
      bottomNavigationBar: const ShellBottomBar(),
    );
  }
}
