import 'package:flutter/painting.dart';

/// Colour tokens read from the Figma `Styles` page.
abstract final class AppColors {
  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color neutral10 = Color(0xFFF1F1F1);
  static const Color neutral20 = Color(0xFFD9D9D9);
  static const Color neutral30 = Color(0xFFC1C1C1);
  static const Color neutral40 = Color(0xFFA9A9A9);
  static const Color neutral50 = Color(0xFF919191);
  static const Color neutral60 = Color(0xFF797979);
  static const Color neutral70 = Color(0xFF606060);
  static const Color neutral80 = Color(0xFF484848);
  static const Color neutral90 = Color(0xFF303030);
  static const Color neutral100 = Color(0xFF181818);

  // Primary (brand red)
  static const Color primary50 = Color(0xFFE23E3E);
  static const Color primary30 = Color(0xFFEE8B8B);
  static const Color primary10 = Color(0xFFF9D8D8);

  // Secondary (amber)
  static const Color secondary0 = Color(0xFFFFF5E6);
  static const Color secondary10 = Color(0xFFFFE1B3);
  static const Color secondary20 = Color(0xFFFFCE80);
  static const Color secondary30 = Color(0xFFFFBA4D);
  static const Color secondary40 = Color(0xFFFFA61A);
  static const Color secondary50 = Color(0xFFFF9C00);
  static const Color secondary60 = Color(0xFFE68C00);
  static const Color secondary70 = Color(0xFFCC7D00);
  static const Color secondary80 = Color(0xFFB36D00);
  static const Color secondary90 = Color(0xFF995E00);
  static const Color secondary100 = Color(0xFF804E00);

  // Status
  static const Color rating = Color(0xFFFFB661);
  static const Color error100 = Color(0xFFEE1133);
  static const Color error10 = Color(0xFFFDE7EB);
  static const Color success100 = Color(0xFF31B057);
  static const Color success10 = Color(0xFFEAF7EE);

  /// Secondary label text (`Food recipe/dark grey` in Figma).
  static const Color darkGrey = Color(0xFF808A96);

  /// Dark translucent fill behind badges laid over photos (`#303030` at 30 %).
  static const Color overlayScrim = Color(0x4D303030);

  /// Soft shadow under the bottom navigation bar (`#6C6C6C` at 8 %).
  static const Color navBarShadow = Color(0x146C6C6C);
}
