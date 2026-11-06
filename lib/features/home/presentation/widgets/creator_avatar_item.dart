import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';
import 'package:good_eating/features/meals/presentation/widgets/creator_line.dart';

/// A creator's portrait with their name in two centred lines beneath it.
class CreatorAvatarItem extends StatelessWidget {
  const CreatorAvatarItem({required this.creator, super.key});

  final PlaceholderCreator creator;

  static const double size = 75;

  /// Portrait, gap, then two lines of 12 px text at their natural height.
  static const double height = size + AppSpacing.sm + 2 * 12 * 1.5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Column(
        children: [
          CreatorAvatar(creator: creator, diameter: size),
          const SizedBox(height: AppSpacing.sm),
          Text(
            // Always break after the first name, as the design does.
            creator.name.replaceFirst(' ', '\n'),
            textAlign: TextAlign.center,
            style: AppTextStyles.smallBold,
          ),
        ],
      ),
    );
  }
}
