/// Text formatting for values shown in the design.
abstract final class Formatters {
  /// `4.5` becomes `4,5`: the design writes ratings with a decimal comma.
  static String rating(double value) =>
      value.toStringAsFixed(1).replaceAll('.', ',');

  /// `15 minutes 10 seconds` becomes `15:10`. Only the seconds are padded.
  static String videoLength(Duration value) {
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '${value.inMinutes}:$seconds';
  }

  /// `10` becomes `10 Mins`.
  static String cookTime(int minutes) => '$minutes Mins';
}
