import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';

/// The meal's country of origin and category as two small pills.
///
/// A blank value is left out, so a recipe missing one still looks complete.
class MealInfoChips extends StatelessWidget {
  const MealInfoChips({required this.area, required this.category, super.key});

  final String area;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (area.isNotEmpty)
          _InfoChip(
            label: area,
            background: AppColors.primary10,
            foreground: AppColors.primary50,
          ),
        if (category.isNotEmpty)
          _InfoChip(
            label: category,
            background: AppColors.neutral10,
            foreground: AppColors.neutral70,
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.controlAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          label,
          style: AppTextStyles.smallBold.copyWith(color: foreground),
        ),
      ),
    );
  }
}
