import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/core/services/link_launcher.dart';
import 'package:good_eating/features/meals/domain/repositories/meal_repository.dart';

import 'fake_link_launcher.dart';
import 'fake_meal_repository.dart';

/// Registers the real dependency graph, then swaps the repository and the link
/// launcher for fakes so nothing in a test reaches the network or opens
/// another app. Returns the repository fake for scripting; the launcher fake
/// is `getIt<LinkLauncher>() as FakeLinkLauncher`.
///
/// Call it before building any widget that resolves dependencies.
Future<FakeMealRepository> setUpDependencies({
  FakeMealRepository? repository,
}) async {
  await getIt.reset();
  configureDependencies();

  final fake = repository ?? FakeMealRepository();
  getIt
    ..unregister<MealRepository>()
    ..registerSingleton<MealRepository>(fake)
    ..unregister<LinkLauncher>()
    ..registerSingleton<LinkLauncher>(FakeLinkLauncher());
  return fake;
}

/// The link launcher fake installed by [setUpDependencies].
FakeLinkLauncher get fakeLinkLauncher =>
    getIt<LinkLauncher>() as FakeLinkLauncher;
