import 'package:flutter/painting.dart';

/// Spacing scale used for padding and gaps. Nothing outside `core/theme`
/// should hard-code a spacing number.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal inset every screen shares in the design.
  static const double screenHorizontal = xl;

  /// Vertical gap between major sections on a screen.
  static const double section = xxl;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
  );
}
