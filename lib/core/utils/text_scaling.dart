import 'package:flutter/widgets.dart';

extension TextScalingContext on BuildContext {
  /// [logicalPixels] grown by the user's text size setting.
  ///
  /// Cards and rows that have a fixed height around some text use this for the
  /// text's share of that height. A hard-coded height is only right at the
  /// default text size; at 130 % or 200 % the text overflows it.
  double scaled(double logicalPixels) =>
      MediaQuery.textScalerOf(this).scale(logicalPixels);
}
