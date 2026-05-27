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
  static const _themeModeKey = 'theme_mode';

  @override
  Future<AppPreferences> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppPreferences(
      languageCode: preferences.getString(_languageCodeKey),
      themeMode: _themeModeFromStorage(preferences.getString(_themeModeKey)),
    );
  }

  @override
  Future<void> save(AppPreferences preferences) async {
    final storage = await SharedPreferences.getInstance();
    final languageCode = preferences.languageCode;
    if (languageCode == null || languageCode.isEmpty) {
      await storage.remove(_languageCodeKey);
    } else {
      await storage.setString(_languageCodeKey, languageCode);
    }
    await storage.setString(_themeModeKey, preferences.themeMode.name);
  }

  AppThemeMode _themeModeFromStorage(String? value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
}
