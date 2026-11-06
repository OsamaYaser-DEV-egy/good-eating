import 'package:good_eating/core/services/link_launcher.dart';

/// Records the links a screen asks to open instead of leaving the test run.
final class FakeLinkLauncher implements LinkLauncher {
  /// What [open] reports. Set it to false to simulate a device that cannot
  /// open the link.
  bool succeeds = true;

  /// Every link requested, in order.
  final List<String> opened = [];

  @override
  Future<bool> open(String url) async {
    opened.add(url);
    return succeeds;
  }
}
