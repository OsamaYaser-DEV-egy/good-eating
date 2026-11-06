import 'package:good_eating/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the "welcome screen seen" flag on this device.
abstract interface class OnboardingLocalDataSource {
  bool isCompleted();

  /// Throws [CacheException] when the flag could not be written.
  Future<void> markCompleted();
}

final class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  const OnboardingLocalDataSourceImpl(this._preferences);

  final SharedPreferences _preferences;

  static const String storageKey = 'onboarding_completed';

  @override
  // Read as a plain value, not with getBool, which throws if something else
  // was stored under this key. Anything that is not exactly true counts as
  // "not completed".
  bool isCompleted() => _preferences.get(storageKey) == true;

  @override
  Future<void> markCompleted() async {
    final saved = await _preferences.setBool(storageKey, true);
    if (!saved) {
      throw const CacheException('The onboarding flag could not be written.');
    }
  }
}
