import 'dart:convert';

import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/core/services/link_launcher.dart';
import 'package:good_eating/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:good_eating/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:good_eating/features/meals/domain/repositories/meal_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_link_launcher.dart';
import 'fake_meal_repository.dart';

/// Registers the real dependency graph, then swaps the meal repository and the
/// link launcher for fakes so nothing in a test reaches the network or opens
/// another app. Returns the meal repository fake for scripting; the launcher
/// fake is [fakeLinkLauncher].
///
/// Saved meals use the real storage code on top of `SharedPreferences`' mock
/// store, which starts empty. Pass [keepStorage] to keep what the previous
/// call left in it: that is how a test simulates closing and reopening the
/// app. Pass [favorites] to script the favorites repository instead.
///
/// Call it before building any widget that resolves dependencies.
Future<FakeMealRepository> setUpDependencies({
  FakeMealRepository? repository,
  bool keepStorage = false,
  FavoritesRepository? favorites,
}) async {
  if (!keepStorage) SharedPreferences.setMockInitialValues({});
  await getIt.reset();
  await configureDependencies();

  final fake = repository ?? FakeMealRepository();
  getIt
    ..unregister<MealRepository>()
    ..registerSingleton<MealRepository>(fake)
    ..unregister<LinkLauncher>()
    ..registerSingleton<LinkLauncher>(FakeLinkLauncher());

  if (favorites != null) {
    getIt
      ..unregister<FavoritesRepository>()
      ..registerSingleton<FavoritesRepository>(favorites);
  }
  return fake;
}

/// The link launcher fake installed by [setUpDependencies].
FakeLinkLauncher get fakeLinkLauncher =>
    getIt<LinkLauncher>() as FakeLinkLauncher;

/// The ids saved on disk right now, newest first, read straight from the
/// store so a test can check what really got written.
Future<List<String>> storedFavoriteIds() async {
  final preferences = await SharedPreferences.getInstance();
  final raw = preferences.getString(FavoritesLocalDataSourceImpl.storageKey);
  if (raw == null) return const [];
  return [
    for (final entry in jsonDecode(raw) as List<dynamic>)
      (entry as Map<String, dynamic>)['id'] as String,
  ];
}
