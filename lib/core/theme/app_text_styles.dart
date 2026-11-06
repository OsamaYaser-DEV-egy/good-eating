import 'package:flutter/painting.dart';

import 'package:good_eating/core/theme/app_colors.dart';

/// Poppins type scale from the Figma `Styles` page.
///
/// Figma's "bold" style is Poppins SemiBold (600), so that is what `*Bold`
/// maps to here. Small and tiny styles use a line height of 1.0, matching the
/// 100 % set in the design.
abstract final class AppTextStyles {
  static const String fontFamily = 'Poppins';

  static const TextStyle h4Bold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.neutral90,
  );

  static const TextStyle h5Bold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.neutral90,
  );

  static const TextStyle paragraphBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.neutral90,
  );

  static const TextStyle paragraphRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.neutral90,
  );

  static const TextStyle labelBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.neutral90,
  );

  static const TextStyle labelRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.neutral90,
  );

  static const TextStyle smallBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1,
    color: AppColors.neutral90,
  );

  static const TextStyle smallRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1,
    color: AppColors.neutral90,
  );

  static const TextStyle tinyRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1,
    color: AppColors.neutral90,
  );
}
