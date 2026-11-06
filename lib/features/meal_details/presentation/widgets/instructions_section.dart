import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';

/// "Instructions" with the recipe's steps numbered in order.
///
/// The design stops at the ingredients, but the brief requires the full
/// preparation steps, so this section is added below them in the same style.
class InstructionsSection extends StatelessWidget {
  const InstructionsSection({required this.steps, super.key});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Instructions', style: AppTextStyles.h5Bold),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          _StepTile(number: i + 1, text: steps[i]),
        ],
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.number, required this.text});

  final int number;
  final String text;

  static const double _badgeSize = 28;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Step $number',
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: _badgeSize,
                child: Center(
                  child: Text(
                    '$number',
                    style: AppTextStyles.smallBold.copyWith(
                      color: AppColors.primary50,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            // Centres the first line on the badge.
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              text,
              style: AppTextStyles.labelRegular.copyWith(
                color: AppColors.neutral70,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
