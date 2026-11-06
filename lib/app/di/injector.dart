import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:good_eating/core/network/api_client.dart';
import 'package:good_eating/core/network/dio_factory.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_cubit.dart';

final GetIt getIt = GetIt.instance;

/// Registers every dependency. This is the only place objects are wired
/// together; nothing else constructs its own collaborators.
void configureDependencies() {
  getIt
    // Core
    ..registerLazySingleton<Dio>(DioFactory.create)
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt()))
    // Presentation
    ..registerFactory<ShellCubit>(ShellCubit.new);
}
