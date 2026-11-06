import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/app/app.dart';

/// Runs the whole app on a [width] by [height] screen and waits for it to
/// settle. Dependencies must already be set up with `setUpDependencies`.
///
/// Home builds its sections lazily, so the default height is tall enough to
/// build all of them.
///
/// Pass `showOnboarding: true` for a first launch, which opens on the welcome
/// screen.
///
/// Pass `settle: false` when a skeleton is meant to stay on screen: its shimmer
/// repeats forever, so the app can never settle. The app is then pumped just
/// long enough for the first frames.
Future<void> pumpApp(
  WidgetTester tester, {
  double width = 375,
  double height = 2400,
  bool settle = true,
  bool showOnboarding = false,
}) async {
  tester.view
    ..physicalSize = Size(width, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(App(showOnboarding: showOnboarding));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 500));
  }
}
