import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_text_styles.dart';

/// Stand-in body for a tab whose screen has not been built yet. Each stage
/// replaces one of these with the real page.
class ShellPlaceholderTab extends StatelessWidget {
  const ShellPlaceholderTab({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(child: Text(title, style: AppTextStyles.h5Bold)),
    );
  }
}
