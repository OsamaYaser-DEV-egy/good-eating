import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:good_eating/core/theme/app_colors.dart';

/// The floating red circle that sits in the nav bar's notch.
class NavBarCenterButton extends StatelessWidget {
  const NavBarCenterButton({
    required this.iconAsset,
    required this.semanticLabel,
    required this.onTap,
    super.key,
  });

  final String iconAsset;
  final String semanticLabel;
  final VoidCallback onTap;

  static const double size = 48;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: AppColors.primary50,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: SvgPicture.asset(
                iconAsset,
                width: _iconSize,
                height: _iconSize,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
