import 'dart:convert';

import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/features/favorites/data/models/favorite_meal_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the saved meals on this device.
abstract interface class FavoritesLocalDataSource {
  /// Newest first. Never throws for unreadable data: see the implementation.
  Future<List<FavoriteMealModel>> read();

  /// Throws [CacheException] when the list could not be written.
  Future<void> write(List<FavoriteMealModel> favorites);
}

/// Keeps the whole list as one JSON string in `SharedPreferences`.
///
/// A few hundred short records fit comfortably in one value, and writing the
/// list as a unit means a crash can never leave it half updated.
final class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  const FavoritesLocalDataSourceImpl(this._preferences);

  final SharedPreferences _preferences;

  static const String storageKey = 'favorite_meals';

  @override
  Future<List<FavoriteMealModel>> read() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return const [];

    // Anything unreadable counts as "nothing saved". Throwing here would leave
    // a corrupt value in place forever, with every later save reading it
    // first; treating it as empty lets the next save replace it.
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const [];
    }
    if (decoded is! List<Object?>) return const [];

    final favorites = <FavoriteMealModel>[];
    for (final entry in decoded) {
      if (entry is! Map<String, dynamic>) continue;
      try {
        favorites.add(FavoriteMealModel.fromJson(entry));
      } on ParsingException {
        continue;
      }
    }
    return favorites;
  }

  @override
  Future<void> write(List<FavoriteMealModel> favorites) async {
    final encoded = jsonEncode([for (final meal in favorites) meal.toJson()]);
    final saved = await _preferences.setString(storageKey, encoded);
    if (!saved) {
      throw const CacheException('The favorites could not be written.');
    }
  }
}
