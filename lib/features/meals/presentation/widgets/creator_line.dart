import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';

/// A round creator portrait.
class CreatorAvatar extends StatelessWidget {
  const CreatorAvatar({
    required this.creator,
    required this.diameter,
    super.key,
  });

  final PlaceholderCreator creator;
  final double diameter;

  /// Portraits are 150 px source images, so decode at twice the largest
  /// size they are shown at rather than at full resolution.
  static const int _decodeWidth = 150;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        creator.avatarAsset,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        cacheWidth: _decodeWidth,
        semanticLabel: creator.name,
      ),
    );
  }
}

/// A portrait with "By Name" beside it, as under the trending cards.
class CreatorLine extends StatelessWidget {
  const CreatorLine({required this.creator, super.key});

  final PlaceholderCreator creator;

  static const double _avatarSize = 32;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CreatorAvatar(creator: creator, diameter: _avatarSize),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'By ${creator.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.smallRegular.copyWith(
              color: AppColors.neutral40,
            ),
          ),
        ),
      ],
    );
  }
}
