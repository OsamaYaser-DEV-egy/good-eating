import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:good_eating/core/constants/app_assets.dart';
import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/formatters.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';

/// "★ 4,5 (300 Reviews)". The rating and review count are placeholders (see
/// `UiPlaceholders`), because TheMealDB has neither.
class MealRatingRow extends StatelessWidget {
  const MealRatingRow({required this.mealId, super.key});

  final String mealId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(AppAssets.starRating),
        const SizedBox(width: AppSpacing.xs),
        Text(
          Formatters.rating(UiPlaceholders.rating(mealId)),
          style: AppTextStyles.labelBold,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            Formatters.reviewCount(UiPlaceholders.reviewCount(mealId)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelRegular.copyWith(
              color: AppColors.neutral40,
            ),
          ),
        ),
      ],
    );
  }
}
