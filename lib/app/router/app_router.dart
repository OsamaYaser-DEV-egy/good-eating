import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/app/router/app_routes.dart';
import 'package:good_eating/app/router/page_transitions.dart';
import 'package:good_eating/features/category_meals/presentation/category_meals_navigation.dart';
import 'package:good_eating/features/category_meals/presentation/pages/category_meals_page.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_cubit.dart';
import 'package:good_eating/features/shell/presentation/pages/app_shell_page.dart';

/// Maps route names to pages. Unknown names fall back to the shell.
abstract final class AppRouter {
  static Route<Object?> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.categoryMeals => _categoryMeals(settings),
      _ => _shell(settings),
    };
  }

  static Route<Object?> _shell(RouteSettings settings) {
    return FadeThroughPageRoute<Object?>(
      settings: settings,
      builder: (_) => BlocProvider(
        create: (_) => getIt<ShellCubit>(),
        child: const AppShellPage(),
      ),
    );
  }

  static Route<Object?> _categoryMeals(RouteSettings settings) {
    final args = settings.arguments;
    if (args is! CategoryMealsArgs) {
      throw ArgumentError.value(
        args,
        'settings.arguments',
        '${AppRoutes.categoryMeals} needs CategoryMealsArgs',
      );
    }
    return FadeThroughPageRoute<Object?>(
      settings: settings,
      builder: (_) => CategoryMealsPage(category: args.category),
    );
  }
}
