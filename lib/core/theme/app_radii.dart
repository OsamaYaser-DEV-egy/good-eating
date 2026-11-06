import 'package:flutter/painting.dart';

/// Corner radii used across cards, chips, buttons and fields.
abstract final class AppRadii {
  static const double sm = 8;

  /// Fields, chips and buttons (the design uses 10 for all three).
  static const double control = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius controlAll = BorderRadius.all(
    Radius.circular(control),
  );
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
