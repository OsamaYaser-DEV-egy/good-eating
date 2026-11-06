import 'package:flutter/material.dart';

import 'package:good_eating/core/constants/app_durations.dart';
import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';

/// One tab in the category row. The selected tab is a filled brand-red pill.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary50 : AppColors.white,
            borderRadius: AppRadii.controlAll,
          ),
          child: ExcludeSemantics(
            child: AnimatedDefaultTextStyle(
              duration: AppDurations.fast,
              style: AppTextStyles.smallBold.copyWith(
                color: selected ? AppColors.white : AppColors.primary30,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
