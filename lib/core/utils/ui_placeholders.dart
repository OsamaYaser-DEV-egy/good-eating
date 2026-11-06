import 'package:equatable/equatable.dart';

import 'package:good_eating/core/constants/app_assets.dart';

/// A fictional recipe author shown in place of data the API does not have.
final class PlaceholderCreator extends Equatable {
  const PlaceholderCreator({
    required this.name,
    required this.avatarAsset,
    required this.location,
  });

  final String name;
  final String avatarAsset;

  /// Where the creator is based, for example "Bali, Indonesia".
  final String location;

  @override
  List<Object?> get props => [name, avatarAsset, location];
}

/// The signed-in user shown on the Profile tab. There are no accounts in
/// TheMealDB, so this is a fixed example taken from the design.
final class PlaceholderProfile extends Equatable {
  const PlaceholderProfile({
    required this.name,
    required this.bio,
    required this.avatarAsset,
    required this.videoCount,
    required this.followerCount,
    required this.followingCount,
  });

  final String name;
  final String bio;
  final String avatarAsset;
  final String videoCount;
  final String followerCount;
  final String followingCount;

  @override
  List<Object?> get props => [
    name,
    bio,
    avatarAsset,
    videoCount,
    followerCount,
    followingCount,
  ];
}

/// Values the design shows but TheMealDB does not return: rating, review
/// count, cook time, video length, recipe author and the signed-in profile.
///
/// Everything is derived from a stable hash of the meal id, so a given meal
/// always shows the same numbers across rebuilds and app launches.
abstract final class UiPlaceholders {
  /// The creators that have a portrait in the design, in the order the
  /// "Popular creators" row shows them.
  static const List<PlaceholderCreator> allCreators = [
    PlaceholderCreator(
      name: 'Troyan Smith',
      avatarAsset: AppAssets.avatarTroyanSmith,
      location: 'Bali, Indonesia',
    ),
    PlaceholderCreator(
      name: 'James Wolden',
      avatarAsset: AppAssets.avatarJamesWolden,
      location: 'Lyon, France',
    ),
    PlaceholderCreator(
      name: 'Niki Samantha',
      avatarAsset: AppAssets.avatarNikiSamantha,
      location: 'Kyoto, Japan',
    ),
    PlaceholderCreator(
      name: 'Roberta Anny',
      avatarAsset: AppAssets.avatarRobertaAnny,
      location: 'Tuscany, Italy',
    ),
  ];

  /// The profile on the Profile tab, as drawn in the design.
  static const PlaceholderProfile profile = PlaceholderProfile(
    name: 'Alessandra Blair',
    bio:
        'Hello world I\u2019m Alessandra Blair, I\u2019m from Italy \u{1F1EE}\u{1F1F9} '
        'I love cooking so much!',
    avatarAsset: AppAssets.avatarAlessandraBlair,
    videoCount: '13',
    followerCount: '14K',
    followingCount: '120',
  );

  /// 4.0 to 5.0 in steps of 0.1.
  static double rating(String mealId) =>
      4 + (_hash(mealId, 'rating') % 11) / 10;

  /// 50 to 500 reviews.
  static int reviewCount(String mealId) => 50 + _hash(mealId, 'reviews') % 451;

  /// 6 to 16 ingredients.
  static int ingredientCount(String mealId) =>
      6 + _hash(mealId, 'ingredients') % 11;

  /// 10 to 60 minutes in steps of 5.
  static int cookMinutes(String mealId) =>
      10 + 5 * (_hash(mealId, 'minutes') % 11);

  /// 5:00 to 25:59.
  static Duration videoLength(String mealId) => Duration(
    minutes: 5 + _hash(mealId, 'video-min') % 21,
    seconds: _hash(mealId, 'video-sec') % 60,
  );

  static PlaceholderCreator creator(String mealId) =>
      allCreators[_hash(mealId, 'creator') % allCreators.length];

  /// 32-bit FNV-1a. `String.hashCode` is not stable across runs, so it
  /// cannot be used for values that must not change between launches.
  ///
  /// The prime is 2^24 + 403, so the multiply is written as a shift plus a
  /// small product. A plain `hash * 0x01000193` reaches 2^56, which JavaScript
  /// numbers (used when the app runs on the web) cannot hold exactly: the low
  /// bits are lost, and every `% n` below would come out as 0. This form
  /// stays under 2^53 and gives identical results on every platform.
  static int _hash(String id, String salt) {
    var hash = 0x811C9DC5;
    for (final unit in '$salt:$id'.codeUnits) {
      hash ^= unit;
      hash = (((hash << 24) & 0xFFFFFFFF) + hash * 403) & 0xFFFFFFFF;
    }
    return hash;
  }
}
