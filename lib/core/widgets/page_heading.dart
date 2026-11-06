import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';

/// The large title at the top of a tab: "Find best recipes for cooking" on
/// Home, "Saved recipes" on the Saved tab.
///
/// It does not add the status-bar inset; wrap it in a `SafeArea`.
class PageHeading extends StatelessWidget {
  const PageHeading({required this.title, super.key});

  final String title;

  /// The design sets the heading 2 px in from the screen padding.
  static const double _leftInset = AppSpacing.screenHorizontal + 2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _leftInset,
        AppSpacing.xl,
        AppSpacing.screenHorizontal,
        AppSpacing.xl,
      ),
      child: Text(title, style: AppTextStyles.h4Bold),
    );
  }
}
