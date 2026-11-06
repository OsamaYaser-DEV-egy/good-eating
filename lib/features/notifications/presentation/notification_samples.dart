import 'package:equatable/equatable.dart';

import 'package:good_eating/core/utils/ui_placeholders.dart';

/// One line on the Notifications tab.
final class NotificationItem extends Equatable {
  const NotificationItem({
    required this.creator,
    required this.message,
    required this.timeAgo,
    this.isUnread = false,
  });

  final PlaceholderCreator creator;

  /// What the creator did, written to follow their name: "liked your recipe".
  final String message;
  final String timeAgo;
  final bool isUnread;

  @override
  List<Object?> get props => [creator, message, timeAgo, isUnread];
}

/// Example notifications. TheMealDB has no accounts, so nothing real can be
/// notified; these fill the screen the design draws, in its two groups.
abstract final class NotificationSamples {
  static const List<PlaceholderCreator> _creators = UiPlaceholders.allCreators;

  static final List<NotificationItem> today = [
    NotificationItem(
      creator: _creators[2],
      message: 'started following you',
      timeAgo: '2 min ago',
      isUnread: true,
    ),
    NotificationItem(
      creator: _creators[1],
      message: 'liked your recipe',
      timeAgo: '1 hour ago',
      isUnread: true,
    ),
    NotificationItem(
      creator: _creators[3],
      message: 'saved your spaghetti recipe',
      timeAgo: '3 hours ago',
    ),
  ];

  static final List<NotificationItem> yesterday = [
    NotificationItem(
      creator: _creators[0],
      message: 'commented: "Looks delicious!"',
      timeAgo: '1 day ago',
    ),
    NotificationItem(
      creator: _creators[2],
      message: 'shared your recipe',
      timeAgo: '1 day ago',
    ),
  ];
}
