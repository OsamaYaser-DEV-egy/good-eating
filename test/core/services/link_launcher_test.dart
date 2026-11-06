import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_eating/core/services/link_launcher.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Stands in for the platform so no real app or browser is opened.
class _FakeUrlLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  final List<String> launched = [];
  PreferredLaunchMode? lastMode;
  bool result = true;
  bool throws = false;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    if (throws) throw PlatformException(code: 'ACTIVITY_NOT_FOUND');
    launched.add(url);
    lastMode = options.mode;
    return result;
  }
}

void main() {
  late _FakeUrlLauncher platform;
  late UrlLauncherLinkLauncher launcher;

  setUp(() {
    platform = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = platform;
    launcher = const UrlLauncherLinkLauncher();
  });

  test('opens an https link outside the app', () async {
    const url = 'https://www.youtube.com/watch?v=4aZr5hZXP_s';

    expect(await launcher.open(url), isTrue);

    expect(platform.launched, [url]);
    expect(platform.lastMode, PreferredLaunchMode.externalApplication);
  });

  test('opens an http link too', () async {
    expect(await launcher.open('http://example.com/recipe'), isTrue);
    expect(platform.launched, ['http://example.com/recipe']);
  });

  test('trims whitespace the API may leave around a link', () async {
    expect(await launcher.open('  https://youtu.be/abc \n'), isTrue);
    expect(platform.launched, ['https://youtu.be/abc']);
  });

  test('refuses schemes other than http and https', () async {
    for (final url in [
      'javascript:alert(1)',
      'file:///etc/passwd',
      'intent://scan/#Intent;scheme=zxing;end',
      'tel:+123456789',
      'market://details?id=com.example',
    ]) {
      expect(await launcher.open(url), isFalse, reason: url);
    }
    expect(platform.launched, isEmpty);
  });

  test('refuses text that is not a link', () async {
    for (final url in ['', '   ', 'not a url', 'youtube.com/watch?v=abc']) {
      expect(await launcher.open(url), isFalse, reason: '"$url"');
    }
    expect(platform.launched, isEmpty);
  });

  test('reports false when nothing on the device can open the link', () async {
    platform.result = false;
    expect(await launcher.open('https://youtu.be/abc'), isFalse);
  });

  test('reports false instead of throwing when the platform fails', () async {
    platform.throws = true;
    expect(await launcher.open('https://youtu.be/abc'), isFalse);
  });
}
