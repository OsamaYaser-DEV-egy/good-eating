import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/features/meals/presentation/widgets/creator_line.dart';
import 'package:good_eating/features/notifications/presentation/notification_samples.dart';

/// One notification: the creator's portrait, what they did, when, and a red
/// dot while it is unread.
class NotificationTile extends StatelessWidget {
  const NotificationTile({required this.item, super.key});

  final NotificationItem item;

  static const double _avatarSize = 48;
  static const double _dotSize = 8;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          '${item.creator.name} ${item.message}, ${item.timeAgo}'
          '${item.isUnread ? ', unread' : ''}',
      child: ExcludeSemantics(
        child: Row(
          children: [
            CreatorAvatar(creator: item.creator, diameter: _avatarSize),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: AppTextStyles.labelRegular,
                      children: [
                        TextSpan(
                          text: item.creator.name,
                          style: AppTextStyles.labelBold,
                        ),
                        TextSpan(text: ' ${item.message}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.timeAgo,
                    style: AppTextStyles.smallRegular.copyWith(
                      color: AppColors.neutral40,
                    ),
                  ),
                ],
              ),
            ),
            if (item.isUnread) ...[
              const SizedBox(width: AppSpacing.md),
              const SizedBox.square(
                dimension: _dotSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
