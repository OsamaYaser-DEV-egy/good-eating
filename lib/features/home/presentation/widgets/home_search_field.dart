import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:good_eating/core/constants/app_assets.dart';
import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';

/// The search box on Home. It looks like a text field but is a button that
/// opens the Search tab, where the real field lives.
class HomeSearchField extends StatelessWidget {
  const HomeSearchField({required this.onTap, super.key});

  final VoidCallback onTap;

  static const String _hint = 'Search recipes';
  static const double _iconBox = 20;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _hint,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.sm,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadii.controlAll,
              border: Border.all(color: AppColors.neutral20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: _iconBox,
                    child: Center(child: SvgPicture.asset(AppAssets.search)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ExcludeSemantics(
                    child: Text(
                      _hint,
                      style: AppTextStyles.labelRegular.copyWith(
                        color: AppColors.neutral30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
