import 'package:equatable/equatable.dart';

/// A fictional recipe author shown in place of data the API does not have.
final class PlaceholderCreator extends Equatable {
  const PlaceholderCreator({required this.name});

  final String name;

  @override
  List<Object?> get props => [name];
}

/// Values the design shows but TheMealDB does not return: rating, review
/// count, cook time, video length and recipe author.
///
/// Everything is derived from a stable hash of the meal id, so a given meal
/// always shows the same numbers across rebuilds and app launches.
abstract final class UiPlaceholders {
  static const List<String> _creatorNames = [
    'Niki Samantha',
    'Roberta Anny',
    'James Wolden',
    'Troyan Smith',
    'Adrianna Curl',
    'Roberto Anny',
  ];

  /// 4.0 to 5.0 in steps of 0.1.
  static double rating(String mealId) =>
      4 + (_hash(mealId, 'rating') % 11) / 10;

  /// 50 to 500 reviews.
  static int reviewCount(String mealId) => 50 + _hash(mealId, 'reviews') % 451;

  /// 10 to 60 minutes in steps of 5.
  static int cookMinutes(String mealId) =>
      10 + 5 * (_hash(mealId, 'minutes') % 11);

  /// 5:00 to 25:59.
  static Duration videoLength(String mealId) => Duration(
    minutes: 5 + _hash(mealId, 'video-min') % 21,
    seconds: _hash(mealId, 'video-sec') % 60,
  );

  static PlaceholderCreator creator(String mealId) => PlaceholderCreator(
    name: _creatorNames[_hash(mealId, 'creator') % _creatorNames.length],
  );

  /// Every creator in the pool, for the "Popular creators" row.
  static List<PlaceholderCreator> get allCreators => [
    for (final name in _creatorNames) PlaceholderCreator(name: name),
  ];

  /// 32-bit FNV-1a. `String.hashCode` is not stable across runs, so it
  /// cannot be used for values that must not change between launches.
  static int _hash(String id, String salt) {
    var hash = 0x811C9DC5;
    for (final unit in '$salt:$id'.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }
}
