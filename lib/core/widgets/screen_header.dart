import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:good_eating/core/constants/app_assets.dart';
import 'package:good_eating/core/constants/app_durations.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';

/// The top of a pushed screen, as drawn in the design: a back arrow, an
/// optional action on the right, and a large title underneath.
///
/// The title cross-fades when it changes, for screens whose title follows a
/// selection. It does not add the status-bar inset; wrap it in a `SafeArea`.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({required this.title, this.trailing, super.key});

  final String title;

  /// Shown at the right end of the arrow row. It should be a 48 px tap
  /// target; the header shifts it so its glyph, not the tap target, sits on
  /// the 20 px margin, as the back arrow does on the left.
  final Widget? trailing;

  /// The arrow is 24 px, but a tap target should be at least 48.
  static const double _tapTarget = 48;
  static const double _arrowSize = 24;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;

    return Padding(
      // The arrow sits 20 px from the edge; its tap target extends 12 px
      // beyond it on every side.
      padding: const EdgeInsets.only(
        left: AppSpacing.screenHorizontal - (_tapTarget - _arrowSize) / 2,
        right: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _BackButton(),
              if (trailing != null) ...[
                const Spacer(),
                Transform.translate(
                  offset: const Offset((_tapTarget - _arrowSize) / 2, 0),
                  child: trailing,
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: (_tapTarget - _arrowSize) / 2,
              top: AppSpacing.xs,
              bottom: AppSpacing.md,
            ),
            child: AnimatedSwitcher(
              duration: AppDurations.fast,
              child: Text(
                title,
                key: ValueKey(title),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h4Bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).maybePop(),
        child: SizedBox.square(
          dimension: ScreenHeader._tapTarget,
          child: Center(child: SvgPicture.asset(AppAssets.arrowLeft)),
        ),
      ),
    );
  }
}
