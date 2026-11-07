import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/text_scaling.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';
import 'package:good_eating/features/meals/presentation/widgets/creator_line.dart';

/// A creator's portrait with their name in two centred lines beneath it.
class CreatorAvatarItem extends StatelessWidget {
  const CreatorAvatarItem({required this.creator, super.key});

  final PlaceholderCreator creator;

  static const double size = 75;

  /// Two lines of 12 px text at their natural height.
  static const double _nameLines = 2 * 12 * 1.5;

  /// Portrait, gap, then the name: 119 at the default text size.
  static double heightOf(BuildContext context) =>
      size + AppSpacing.sm + context.scaled(_nameLines);

  /// How much of the portrait's width the longest name ("Samantha") needs,
  /// relative to the text size. At the default text size it fits the 75 px
  /// portrait; at larger sizes the column widens so the name never wraps to a
  /// third line.
  static const double _nameWidthRatio = 0.9;

  /// The column's width: the portrait's, or wider when the text is larger.
  static double widthOf(BuildContext context) =>
      math.max(size, context.scaled(size) * _nameWidthRatio);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthOf(context),
      child: Column(
        children: [
          CreatorAvatar(creator: creator, diameter: size),
          const SizedBox(height: AppSpacing.sm),
          Text(
            // Always break after the first name, as the design does.
            creator.name.replaceFirst(' ', '\n'),
            textAlign: TextAlign.center,
            maxLines: 2,
            softWrap: false,
            style: AppTextStyles.smallBold,
          ),
        ],
      ),
    );
  }
}
