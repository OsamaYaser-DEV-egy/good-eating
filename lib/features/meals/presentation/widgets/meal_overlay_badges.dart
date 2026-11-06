import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:good_eating/core/constants/app_assets.dart';
import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/formatters.dart';
import 'package:good_eating/core/widgets/overlay_badge.dart';

/// Star and rating, laid over the top corner of a photo.
class MealRatingBadge extends StatelessWidget {
  const MealRatingBadge({required this.rating, super.key});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return OverlayBadge(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(AppAssets.star),
          const SizedBox(width: AppSpacing.xs),
          Text(
            Formatters.rating(rating),
            style: AppTextStyles.labelBold.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

/// Video length, laid over the bottom corner of a photo.
class MealDurationBadge extends StatelessWidget {
  const MealDurationBadge({required this.duration, super.key});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return OverlayBadge(
      child: Text(
        Formatters.videoLength(duration),
        style: AppTextStyles.smallRegular.copyWith(color: AppColors.white),
      ),
    );
  }
}
