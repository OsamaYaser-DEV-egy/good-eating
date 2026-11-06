import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:good_eating/app/app.dart';
import 'package:good_eating/app/di/injector.dart';

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

  runApp(const App());
}
