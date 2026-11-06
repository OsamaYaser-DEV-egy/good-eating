import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:good_eating/core/constants/app_assets.dart';
import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';

/// A section title with an optional "See all →" button on the right.
///
/// The button is hidden when [onSeeAll] is null, so a section never shows a
/// control that goes nowhere.
class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.onSeeAll, super.key});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final onSeeAll = this.onSeeAll;

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h5Bold,
            ),
          ),
          if (onSeeAll != null) _SeeAllButton(onTap: onSeeAll),
        ],
      ),
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'See all',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Text(
                'See all',
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.primary50,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            SvgPicture.asset(AppAssets.arrowRight),
          ],
        ),
      ),
    );
  }
}
