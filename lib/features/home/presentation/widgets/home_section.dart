import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/widgets/section_header.dart';

/// The shared frame of a Home section: a header, then [child] below it,
/// with the design's 12 px above and below.
class HomeSection extends StatelessWidget {
  const HomeSection({
    required this.title,
    required this.child,
    this.onSeeAll,
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, onSeeAll: onSeeAll),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

/// Shown inside a section whose request succeeded but returned nothing.
class SectionEmpty extends StatelessWidget {
  const SectionEmpty({required this.height, required this.message, super.key});

  final double height;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.labelRegular.copyWith(
            color: AppColors.neutral60,
          ),
        ),
      ),
    );
  }
}
