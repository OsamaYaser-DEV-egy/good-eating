import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/features/meals/domain/repositories/meal_repository.dart';

import 'fake_meal_repository.dart';

/// Registers the real dependency graph, then swaps the repository for a fake
/// so nothing in a test reaches the network. Returns the fake for scripting.
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
    ..registerSingleton<MealRepository>(fake);
  return fake;
}
