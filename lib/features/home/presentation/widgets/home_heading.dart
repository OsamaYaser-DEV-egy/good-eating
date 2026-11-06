import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';

/// "Find best recipes for cooking", at the top of Home.
class HomeHeading extends StatelessWidget {
  const HomeHeading({super.key});

  /// The design sets the heading 2 px in from the screen padding.
  static const double _leftInset = AppSpacing.screenHorizontal + 2;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        _leftInset,
        AppSpacing.xl,
        AppSpacing.screenHorizontal,
        AppSpacing.xl,
      ),
      child: Text(
        'Find best recipes\nfor cooking',
        style: AppTextStyles.h4Bold,
      ),
    );
  }
}
