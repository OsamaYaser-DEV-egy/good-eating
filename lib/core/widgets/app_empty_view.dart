import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';

/// A friendly "nothing here" message, used instead of an error when a request
/// succeeded but returned no items.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    required this.icon,
    required this.title,
    this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;

  static const double _iconSize = 48;

  @override
  Widget build(BuildContext context) {
    final message = this.message;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: _iconSize, color: AppColors.neutral30),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.paragraphBold,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelRegular.copyWith(
                  color: AppColors.neutral60,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
