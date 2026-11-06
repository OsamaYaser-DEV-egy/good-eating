import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real Poppins before any test runs.
///
/// Without this `flutter_test` draws every glyph with a fixed-width test font,
/// so text is far wider than in the app and overflow checks would be
/// meaningless. With it, layout in tests matches layout on a device.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final poppins = FontLoader('Poppins')
    ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'));
  await poppins.load();

  await testMain();
}
