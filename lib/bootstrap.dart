import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:good_eating/app/app.dart';
import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/features/onboarding/domain/usecases/is_onboarding_completed.dart';

/// Prepares everything the app needs before the first frame, then runs it.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Errors thrown outside the Flutter framework (timers, isolates, futures
  // nobody awaited) would otherwise be dropped without a trace.
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    debugPrint('Uncaught error: $error\n$stackTrace');
    return true;
  };

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await configureDependencies();

  runApp(App(showOnboarding: await shouldShowOnboarding()));
}

/// Whether this is the first launch, so the welcome screen should open first.
///
/// If the flag cannot be read the welcome screen is skipped: being sent
/// straight into the app is better than being shown a welcome screen on every
/// launch.
Future<bool> shouldShowOnboarding() async {
  final result = await getIt<IsOnboardingCompleted>()(const NoParams());
  return result.fold(
    onSuccess: (completed) => !completed,
    onFailure: (_) => false,
  );
}
