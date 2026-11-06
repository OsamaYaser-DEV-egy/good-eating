import 'package:flutter/widgets.dart';

import 'package:good_eating/core/theme/app_colors.dart';

/// Paints the white bottom bar with the circular notch from the Figma `Nav Bar`
/// component (`139:3640`).
///
/// The notch geometry is the exact bezier path from the design, 109.75 wide and
/// 41 deep, centred horizontally. The bar itself stretches to any width.
final class BottomNavBarPainter extends CustomPainter {
  const BottomNavBarPainter();

  /// Figma's drop shadow: 4 blur, 1 up, `#6C6C6C` at 8 %.
  static const double _shadowBlurSigma = 4;
  static const double _shadowLift = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _barPath(size);

    canvas
      ..save()
      ..translate(0, -_shadowLift)
      ..drawPath(
        path,
        Paint()
          ..color = AppColors.navBarShadow
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            _shadowBlurSigma,
          ),
      )
      ..restore()
      ..drawPath(path, Paint()..color = AppColors.white);
  }

  Path _barPath(Size size) {
    final c = size.width / 2;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(c - 54.875, 0)
      ..cubicTo(c - 45.128, 0, c - 36.871, 7.1439, c - 32.855, 16.0252)
      ..cubicTo(c - 27.656, 27.5251, c - 17.772, 41, c, 41)
      ..cubicTo(c + 17.772, 41, c + 27.656, 27.5251, c + 32.855, 16.0252)
      ..cubicTo(c + 36.871, 7.1439, c + 45.128, 0, c + 54.875, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldRepaint(BottomNavBarPainter oldDelegate) => false;
}
