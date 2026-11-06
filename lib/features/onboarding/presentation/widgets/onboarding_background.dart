import 'package:flutter/material.dart';

import 'package:good_eating/core/constants/app_assets.dart';
import 'package:good_eating/core/theme/app_colors.dart';

/// The full-bleed backdrop of the welcome screen, with a dark scrim so the
/// white text on top stays readable whatever the photo looks like.
///
/// The photo is optional (see [AppAssets.onboardingPhoto]). Without it the
/// screen shows a dark gradient, which looks intentional rather than broken.
class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key});

  /// Darker at the top for the status bar, clear in the middle, darkest at
  /// the bottom behind the headline and button.
  static const LinearGradient _scrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x66000000), Color(0x00000000), Color(0xB3000000)],
    stops: [0, 0.4, 1],
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppAssets.onboardingPhoto,
          fit: BoxFit.cover,
          // Shown when the photo has not been added.
          errorBuilder: (context, error, stackTrace) =>
              const _FallbackBackdrop(),
        ),
        const DecoratedBox(decoration: BoxDecoration(gradient: _scrim)),
      ],
    );
  }
}

class _FallbackBackdrop extends StatelessWidget {
  const _FallbackBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.35),
          radius: 1.1,
          colors: [AppColors.neutral70, AppColors.neutral100],
        ),
      ),
    );
  }
}
