/// Hero tags for meal photos.
///
/// A meal can appear in several places at once (Trending and the selected
/// category often show the same recipe), and two heroes with the same tag on
/// one screen break navigation. Each place therefore has its own scope.
abstract final class HeroTags {
  static const String trending = 'trending';
  static const String popular = 'popular';
  static const String recent = 'recent';
  static const String grid = 'grid';
  static const String favorites = 'favorites';

  /// The tag for the photo of [mealId] shown in [scope].
  static String meal({required String scope, required String mealId}) =>
      '$scope-meal-$mealId';
}
