import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/app/router/app_router.dart';
import 'package:good_eating/app/router/app_routes.dart';
import 'package:good_eating/core/theme/app_theme.dart';
import 'package:good_eating/features/meals/presentation/cubit/categories_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Provided above the navigator so pushed screens (the category grid, for
    // one) can read the same category list as the shell.
    return BlocProvider(
      create: (_) => getIt<CategoriesCubit>()..load(),
      child: MaterialApp(
        title: 'Good Eating',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.shell,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
