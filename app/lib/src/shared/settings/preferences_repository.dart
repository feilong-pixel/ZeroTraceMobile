import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences.dart';

abstract interface class PreferencesRepository {
  Future<AppPreferences> load();

  Future<void> save(AppPreferences preferences);
}

class InMemoryPreferencesRepository implements PreferencesRepository {
  InMemoryPreferencesRepository([AppPreferences? initialPreferences])
      : _preferences = initialPreferences ?? const AppPreferences();

  AppPreferences _preferences;

  @override
  Future<AppPreferences> load() async => _preferences;

  @override
  Future<void> save(AppPreferences preferences) async {
    _preferences = preferences;
  }
}

class SharedPreferencesRepository implements PreferencesRepository {
  const SharedPreferencesRepository();

  static const _languageCodeKey = 'language_code';

  @override
  Future<AppPreferences> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppPreferences(
      languageCode: preferences.getString(_languageCodeKey),
    );
  }

  @override
  Future<void> save(AppPreferences preferences) async {
    final storage = await SharedPreferences.getInstance();
    final languageCode = preferences.languageCode;
    if (languageCode == null || languageCode.isEmpty) {
      await storage.remove(_languageCodeKey);
      return;
    }
    await storage.setString(_languageCodeKey, languageCode);
  }
}
