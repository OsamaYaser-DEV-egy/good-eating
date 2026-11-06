import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:good_eating/core/network/api_client.dart';
import 'package:good_eating/core/network/dio_factory.dart';
import 'package:good_eating/core/services/link_launcher.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_cubit.dart';
import 'package:good_eating/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:good_eating/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:good_eating/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:good_eating/features/favorites/domain/usecases/get_favorites.dart';
import 'package:good_eating/features/favorites/domain/usecases/save_favorites.dart';
import 'package:good_eating/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:good_eating/features/home/presentation/cubit/home_feed_cubit.dart';
import 'package:good_eating/features/meal_details/presentation/cubit/meal_details_cubit.dart';
import 'package:good_eating/features/meals/data/datasources/meal_remote_data_source.dart';
import 'package:good_eating/features/meals/data/repositories/meal_repository_impl.dart';
import 'package:good_eating/features/meals/domain/repositories/meal_repository.dart';
import 'package:good_eating/features/meals/domain/usecases/get_categories.dart';
import 'package:good_eating/features/meals/domain/usecases/get_meal_details.dart';
import 'package:good_eating/features/meals/domain/usecases/get_meals_by_category.dart';
import 'package:good_eating/features/meals/domain/usecases/search_meals.dart';
import 'package:good_eating/features/meals/presentation/cubit/categories_cubit.dart';
import 'package:good_eating/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:good_eating/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:good_eating/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:good_eating/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:good_eating/features/onboarding/domain/usecases/is_onboarding_completed.dart';
import 'package:good_eating/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:good_eating/features/search/presentation/cubit/search_cubit.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

/// Registers every dependency. This is the only place objects are wired
/// together; nothing else constructs its own collaborators.
///
/// Async because `SharedPreferences` has to be opened before anything can use
/// it.
Future<void> configureDependencies() async {
  final preferences = await SharedPreferences.getInstance();

  getIt
    // Core
    ..registerSingleton<SharedPreferences>(preferences)
    ..registerLazySingleton<Dio>(DioFactory.create)
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt()))
    ..registerLazySingleton<LinkLauncher>(UrlLauncherLinkLauncher.new)
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
    // Favorites
    ..registerLazySingleton<FavoritesLocalDataSource>(
      () => FavoritesLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetFavorites>(() => GetFavorites(getIt()))
    ..registerLazySingleton<SaveFavorites>(() => SaveFavorites(getIt()))
    // Onboarding
    ..registerLazySingleton<OnboardingLocalDataSource>(
      () => OnboardingLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<IsOnboardingCompleted>(
      () => IsOnboardingCompleted(getIt()),
    )
    ..registerLazySingleton<CompleteOnboarding>(
      () => CompleteOnboarding(getIt()),
    )
    // Presentation
    ..registerFactory<ShellCubit>(ShellCubit.new)
    ..registerFactory<OnboardingCubit>(
      () => OnboardingCubit(completeOnboarding: getIt()),
    )
    ..registerFactory<SearchCubit>(() => SearchCubit(searchMeals: getIt()))
    ..registerFactory<FavoritesCubit>(
      () => FavoritesCubit(getFavorites: getIt(), saveFavorites: getIt()),
    )
    ..registerFactory<CategoriesCubit>(() => CategoriesCubit(getIt()))
    ..registerFactory<CategoryMealsCubit>(
      () => CategoryMealsCubit(
        getCategories: getIt(),
        getMealsByCategory: getIt(),
      ),
    )
    ..registerFactoryParam<MealDetailsCubit, String, void>(
      (mealId, _) => MealDetailsCubit(getMealDetails: getIt(), mealId: mealId),
    )
    ..registerFactory<HomeFeedCubit>(
      () => HomeFeedCubit(getCategories: getIt(), getMealsByCategory: getIt()),
    );
}
