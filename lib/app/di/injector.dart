import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:good_eating/core/network/api_client.dart';
import 'package:good_eating/core/network/dio_factory.dart';
import 'package:good_eating/features/meals/data/datasources/meal_remote_data_source.dart';
import 'package:good_eating/features/meals/data/repositories/meal_repository_impl.dart';
import 'package:good_eating/features/meals/domain/repositories/meal_repository.dart';
import 'package:good_eating/features/meals/domain/usecases/get_categories.dart';
import 'package:good_eating/features/meals/domain/usecases/get_meal_details.dart';
import 'package:good_eating/features/meals/domain/usecases/get_meals_by_category.dart';
import 'package:good_eating/features/meals/domain/usecases/search_meals.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_cubit.dart';

final GetIt getIt = GetIt.instance;

/// Registers every dependency. This is the only place objects are wired
/// together; nothing else constructs its own collaborators.
void configureDependencies() {
  getIt
    // Core
    ..registerLazySingleton<Dio>(DioFactory.create)
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt()))
    // Meals: data
    ..registerLazySingleton<MealRemoteDataSource>(
      () => MealRemoteDataSourceImpl(getIt()),
    )
    // A singleton, because the repository owns the in-memory cache.
    ..registerLazySingleton<MealRepository>(() => MealRepositoryImpl(getIt()))
    // Meals: domain
    ..registerLazySingleton<GetCategories>(() => GetCategories(getIt()))
    ..registerLazySingleton<GetMealsByCategory>(
      () => GetMealsByCategory(getIt()),
    )
    ..registerLazySingleton<GetMealDetails>(() => GetMealDetails(getIt()))
    ..registerLazySingleton<SearchMeals>(() => SearchMeals(getIt()))
    // Presentation
    ..registerFactory<ShellCubit>(ShellCubit.new);
}
