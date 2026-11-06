import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/app/router/app_routes.dart';
import 'package:good_eating/app/router/page_transitions.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_cubit.dart';
import 'package:good_eating/features/shell/presentation/pages/app_shell_page.dart';

/// Maps route names to pages. Unknown names fall back to the shell.
abstract final class AppRouter {
  static Route<Object?> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.shell => _shell(settings),
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
}
