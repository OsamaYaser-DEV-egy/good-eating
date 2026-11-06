/// Animation and interaction timings shared across the app.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  /// Delay between consecutive items in a staggered entrance animation.
  static const Duration stagger = Duration(milliseconds: 60);

  /// How long the search field waits after the last keystroke before querying.
  static const Duration searchDebounce = Duration(milliseconds: 300);
}
