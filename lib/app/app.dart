import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/app/router/app_router.dart';
import 'package:good_eating/app/router/app_routes.dart';
import 'package:good_eating/core/theme/app_theme.dart';
import 'package:good_eating/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:good_eating/features/favorites/presentation/widgets/save_failure_listener.dart';
import 'package:good_eating/features/meals/presentation/cubit/categories_cubit.dart';

class App extends StatelessWidget {
  const App({this.showOnboarding = false, super.key});

  /// Whether to open on the welcome screen. True on the very first launch.
  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    // Provided above the navigator so pushed screens (the category grid and
    // the details screen) read the same category list and the same saved
    // meals as the shell.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CategoriesCubit>()..load()),
        BlocProvider(create: (_) => getIt<FavoritesCubit>()..load()),
      ],
      child: MaterialApp(
        title: 'Good Eating',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: showOnboarding ? AppRoutes.onboarding : AppRoutes.shell,
        // The default would also build "/" underneath "/onboarding", so Home
        // would load behind the welcome screen and Back would reveal it.
        onGenerateInitialRoutes: (name) => [
          AppRouter.onGenerateRoute(RouteSettings(name: name)),
        ],
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) =>
            SaveFailureListener(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
