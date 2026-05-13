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
