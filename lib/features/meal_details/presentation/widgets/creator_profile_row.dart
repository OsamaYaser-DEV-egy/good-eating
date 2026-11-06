import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:good_eating/core/constants/app_assets.dart';
import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';
import 'package:good_eating/features/meals/presentation/widgets/creator_line.dart';

/// The recipe's author: portrait, name, location and a Follow button.
///
/// TheMealDB has no authors, so the creator is a placeholder (see
/// `UiPlaceholders`) and the Follow button is for show: it has no account
/// behind it to follow.
class CreatorProfileRow extends StatelessWidget {
  const CreatorProfileRow({required this.mealId, super.key});

  final String mealId;

  static const double _avatarSize = 41;

  /// The gap between the portrait and the name, from the design.
  static const double _avatarGap = 10;

  @override
  Widget build(BuildContext context) {
    final creator = UiPlaceholders.creator(mealId);

    return Row(
      children: [
        CreatorAvatar(creator: creator, diameter: _avatarSize),
        const SizedBox(width: _avatarGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                creator.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.paragraphBold.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
              Row(
                children: [
                  SvgPicture.asset(AppAssets.location),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      creator.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelRegular.copyWith(
                        color: AppColors.neutral40,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const _FollowButton(),
      ],
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: AppRadii.controlAll,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          'Follow',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
