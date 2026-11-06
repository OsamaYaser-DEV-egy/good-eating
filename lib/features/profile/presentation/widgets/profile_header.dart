import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';

/// The top of the profile: portrait, "Edit profile", name and bio.
///
/// TheMealDB has no accounts, so the person shown is a fixed example from the
/// design (see `UiPlaceholders.profile`). "Edit profile" has no account behind
/// it and does nothing.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  static const double _avatarSize = 100;

  /// The bio wraps at this width in the design.
  static const double _bioWidth = 256;

  /// The portrait is a 321 by 479 photo; decode it at twice its shown size.
  static const int _decodeWidth = 200;

  @override
  Widget build(BuildContext context) {
    const profile = UiPlaceholders.profile;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Image(
                  image: ResizeImage(
                    AssetImage(profile.avatarAsset),
                    width: _decodeWidth,
                  ),
                  width: _avatarSize,
                  height: _avatarSize,
                  fit: BoxFit.cover,
                  semanticLabel: 'Profile photo',
                ),
              ),
              const Spacer(),
              const _EditProfileButton(),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(profile.name, style: AppTextStyles.h5Bold),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: _bioWidth,
            child: Text(
              profile.bio,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                height: 1.4,
                color: AppColors.neutral40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Edit profile',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadii.controlAll,
            border: Border.all(color: AppColors.primary50),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              'Edit profile',
              style: AppTextStyles.labelBold.copyWith(
                color: AppColors.primary50,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
