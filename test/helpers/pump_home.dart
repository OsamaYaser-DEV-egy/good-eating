import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/app/router/app_router.dart';
import 'package:good_eating/core/theme/app_theme.dart';
import 'package:good_eating/features/home/presentation/pages/home_page.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_cubit.dart';

import 'test_app_providers.dart';

/// Builds Home the way the app does: the shared cubits and the shell's
/// `ShellCubit` above it. Dependencies must already be set up with
/// `setUpDependencies`.
///
/// The screen is [width] by [height] logical pixels. Home scrolls and builds
/// its sections lazily, so the default is tall enough to build all of them;
/// pass a phone-sized [height] to test what a user actually sees.
///
/// Returns the [ShellCubit] so tests can see which tab was requested.
Future<ShellCubit> pumpHome(
  WidgetTester tester, {
  double width = 375,
  double height = 2400,
}) async {
  tester.view
    ..physicalSize = Size(width, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final shell = getIt<ShellCubit>();
  addTearDown(shell.close);

  await tester.pumpWidget(
    TestAppProviders(
      shell: shell,
      child: MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const Scaffold(extendBody: true, body: HomePage()),
      ),
    ),
  );
  return shell;
}
