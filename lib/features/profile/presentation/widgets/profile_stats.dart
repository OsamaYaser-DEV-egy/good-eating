import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';

/// The four counts under the bio, spread evenly across the width, then a 1 px
/// divider.
///
/// "Recipe" is the real number of saved meals. The other three are examples
/// from the design, because there are no accounts to count.
class ProfileStats extends StatelessWidget {
  const ProfileStats({required this.recipeCount, super.key});

  /// The number of saved meals, or a dash while that is not known yet.
  final String recipeCount;

  @override
  Widget build(BuildContext context) {
    const profile = UiPlaceholders.profile;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.xl,
            AppSpacing.screenHorizontal,
            0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(label: 'Recipe', value: recipeCount),
              _Stat(label: 'Videos', value: profile.videoCount),
              _Stat(label: 'Followers', value: profile.followerCount),
              _Stat(label: 'Following', value: profile.followingCount),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SizedBox(
          height: 1,
          width: double.infinity,
          child: ColoredBox(color: AppColors.neutral20),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  /// Gap between the label and the number.
  static const double _gap = 2;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      child: ExcludeSemantics(
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.smallRegular.copyWith(
                color: AppColors.neutral40,
              ),
            ),
            const SizedBox(height: _gap),
            Text(value, style: AppTextStyles.h5Bold),
          ],
        ),
      ),
    );
  }
}
