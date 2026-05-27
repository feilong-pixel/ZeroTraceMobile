import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_settings_scope.dart';
import 'routes.dart';
import 'theme.dart';
import '../shared/i18n/app_language.dart';
import '../shared/i18n/app_localizations.dart';
import '../shared/settings/app_preferences.dart';
import '../shared/settings/preferences_repository.dart';

class ZeroTraceMobileApp extends StatefulWidget {
  const ZeroTraceMobileApp({
    super.key,
    PreferencesRepository? preferencesRepository,
  }) : _preferencesRepository = preferencesRepository;

  final PreferencesRepository? _preferencesRepository;

  @override
  State<ZeroTraceMobileApp> createState() => _ZeroTraceMobileAppState();
}

class _ZeroTraceMobileAppState extends State<ZeroTraceMobileApp> {
  late final PreferencesRepository _preferencesRepository;
  AppPreferences _preferences = const AppPreferences();
  AppLanguage _language = AppLanguage.fallback;

  @override
  void initState() {
    super.initState();
    _preferencesRepository =
        widget._preferencesRepository ?? const SharedPreferencesRepository();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await _preferencesRepository.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _preferences = preferences;
      _language = AppLanguage.fromLanguageCode(preferences.languageCode);
    });
  }

  Future<void> _setLanguage(AppLanguage language) async {
    final preferences = _preferences.copyWith(
      languageCode: language.locale.languageCode,
    );
    setState(() {
      _preferences = preferences;
      _language = language;
    });
    await _preferencesRepository.save(preferences);
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      language: _language,
      onLanguageChanged: _setLanguage,
      child: MaterialApp(
        title: 'ExtraSync',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: _language.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        initialRoute: AppRoutes.dashboard,
        routes: AppRoutes.routes,
      ),
    );
  }
}
