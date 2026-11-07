import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:good_eating/app/router/app_routes.dart';
import 'package:good_eating/core/constants/app_assets.dart';
import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/widgets/primary_button.dart';
import 'package:good_eating/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:good_eating/features/onboarding/presentation/widgets/onboarding_background.dart';

/// The welcome screen: "Let's Cooking" over a dark backdrop, and a button
/// that opens the app.
class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  static const String _headline = 'Let’s\nCooking';
  static const String _subtitle = 'Find best recipes for cooking';

  /// The button is 205 wide in the design, not full width.
  static const double _buttonWidth = 205;
  static const double _afterHeadline = AppSpacing.lg;
  static const double _afterSubtitle = AppSpacing.xxxl + AppSpacing.sm;
  static const double _bottomGap = AppSpacing.xxxl + AppSpacing.lg;

  @override
  Widget build(BuildContext context) {
    // The backdrop is dark, so the status bar needs light icons. This applies
    // only while this screen is showing.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listenWhen: (previous, current) => current == OnboardingState.done,
        listener: (context, state) =>
            Navigator.of(context).pushReplacementNamed(AppRoutes.shell),
        child: Scaffold(
          backgroundColor: AppColors.neutral100,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const OnboardingBackground(),
              SafeArea(
                // The content is centred on a tall screen and scrolls on a
                // short one, or when the text size is large.
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: AppSpacing.screenPadding,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: AppSpacing.lg),
                            const _PremiumLine(),
                            const Spacer(),
                            Text(
                              _headline,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.displayBold.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: _afterHeadline),
                            Text(
                              _subtitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelRegular.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: _afterSubtitle),
                            SizedBox(
                              width: _buttonWidth,
                              child: PrimaryButton(
                                label: 'Start cooking',
                                icon: SvgPicture.asset(
                                  AppAssets.arrowRight,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                onPressed: context
                                    .read<OnboardingCubit>()
                                    .start,
                              ),
                            ),
                            const SizedBox(height: _bottomGap),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "★ 60k+ Premium recipes" at the top of the screen.
class _PremiumLine extends StatelessWidget {
  const _PremiumLine();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(AppAssets.star),
          const SizedBox(width: AppSpacing.sm),
          Text.rich(
            TextSpan(
              style: AppTextStyles.labelRegular.copyWith(
                color: AppColors.white,
              ),
              children: [
                TextSpan(
                  text: '60k+',
                  style: AppTextStyles.labelBold.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const TextSpan(text: ' Premium recipes'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
