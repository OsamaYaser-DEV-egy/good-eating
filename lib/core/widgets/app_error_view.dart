import 'package:flutter/material.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/widgets/primary_button.dart';

IconData _iconFor(Failure failure) => switch (failure) {
  NetworkFailure() || TimeoutFailure() => Icons.wifi_off_rounded,
  _ => Icons.error_outline_rounded,
};

/// A full-area error with the failure's message and a "Try again" button.
class AppErrorView extends StatelessWidget {
  const AppErrorView({required this.failure, required this.onRetry, super.key});

  final Failure failure;
  final VoidCallback onRetry;

  static const double _iconSize = 48;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _iconFor(failure),
              size: _iconSize,
              color: AppColors.neutral30,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelRegular.copyWith(
                color: AppColors.neutral60,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(label: 'Try again', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

/// A one-line error for a single section that failed while the rest of the
/// screen is fine.
class AppInlineError extends StatelessWidget {
  const AppInlineError({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          Icon(_iconFor(failure), color: AppColors.neutral40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              failure.message,
              style: AppTextStyles.smallRegular.copyWith(
                color: AppColors.neutral60,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Try again',
              style: AppTextStyles.smallBold.copyWith(
                color: AppColors.primary50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
