import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';

/// The app's filled brand-red button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Shown after the label, as in the design's "Start cooking →".
  final Widget? icon;

  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary50,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.neutral20,
        minimumSize: const Size(0, _height),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.controlAll),
        textStyle: AppTextStyles.labelBold,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
          ),
          if (icon != null) ...[const SizedBox(width: AppSpacing.sm), icon!],
        ],
      ),
    );
  }
}
