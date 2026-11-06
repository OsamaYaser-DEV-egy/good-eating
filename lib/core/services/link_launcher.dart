import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a web link outside the app.
///
/// An interface so screens can be tested without leaving the test run.
abstract interface class LinkLauncher {
  /// Returns whether a link was opened. It never throws: an unusable url or a
  /// device with nothing to open it simply returns false.
  Future<bool> open(String url);
}

/// Opens links in the YouTube app or the browser through `url_launcher`.
final class UrlLauncherLinkLauncher implements LinkLauncher {
  const UrlLauncherLinkLauncher();

  /// Links come from the API, so only ordinary web links are followed. This
  /// keeps a malformed or hostile value from launching another app's scheme.
  static const Set<String> _allowedSchemes = {'http', 'https'};

  @override
  Future<bool> open(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !_allowedSchemes.contains(uri.scheme)) return false;

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  }
}
