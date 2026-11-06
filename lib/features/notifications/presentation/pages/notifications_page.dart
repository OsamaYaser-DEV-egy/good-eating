import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/widgets/app_bottom_nav_bar.dart';
import 'package:good_eating/core/widgets/page_heading.dart';
import 'package:good_eating/features/notifications/presentation/notification_samples.dart';
import 'package:good_eating/features/notifications/presentation/widgets/notification_tile.dart';

/// The Notifications tab: what happened today and yesterday.
///
/// There are no accounts in TheMealDB, so the notifications are examples (see
/// `NotificationSamples`). The design's frame for this screen could not be read
/// when this was built, so it follows the structure that was known (a heading,
/// then "Today" and "Yesterday" groups) in the app's own style.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const double _groupGap = AppSpacing.xxl;
  static const double _rowGap = AppSpacing.xl;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.only(
          bottom: AppBottomNavBar.heightOf(context) + AppSpacing.md,
        ),
        children: [
          const PageHeading(title: 'Notifications'),
          _Group(title: 'Today', items: NotificationSamples.today),
          const SizedBox(height: _groupGap),
          _Group(title: 'Yesterday', items: NotificationSamples.yesterday),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.items});

  final String title;
  final List<NotificationItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h5Bold),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: NotificationsPage._rowGap),
            NotificationTile(item: items[i]),
          ],
        ],
      ),
    );
  }
}
