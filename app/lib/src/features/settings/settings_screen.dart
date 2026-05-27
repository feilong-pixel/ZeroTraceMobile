import 'package:flutter/material.dart';

import '../../app/app_settings_scope.dart';
import '../../shared/i18n/app_language.dart';
import '../../shared/i18n/app_localizations.dart';
import '../../shared/settings/app_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showLanguagePicker(BuildContext context) async {
    final settings = AppSettingsScope.of(context);
    final selected = await showDialog<AppLanguage>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return SimpleDialog(
          title: Text(l10n.text('settings.language.title')),
          children: [
            RadioGroup<AppLanguage>(
              groupValue: settings.language,
              onChanged: (value) => Navigator.of(context).pop(value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final language in AppLanguage.values)
                    RadioListTile<AppLanguage>(
                      value: language,
                      title: Text(language.displayName),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
    if (selected == null || selected == settings.language) {
      return;
    }
    settings.onLanguageChanged(selected);
  }

  Future<void> _showThemePicker(BuildContext context) async {
    final settings = AppSettingsScope.of(context);
    final selected = await showDialog<AppThemeMode>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return SimpleDialog(
          title: Text(l10n.text('settings.theme.title')),
          children: [
            RadioGroup<AppThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (value) => Navigator.of(context).pop(value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final themeMode in AppThemeMode.values)
                    RadioListTile<AppThemeMode>(
                      value: themeMode,
                      title: Text(_themeModeLabel(l10n, themeMode)),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
    if (selected == null || selected == settings.themeMode) {
      return;
    }
    settings.onThemeModeChanged(selected);
  }

  String _themeModeLabel(AppLocalizations l10n, AppThemeMode themeMode) {
    return switch (themeMode) {
      AppThemeMode.system => l10n.text('settings.theme.system'),
      AppThemeMode.light => l10n.text('settings.theme.light'),
      AppThemeMode.dark => l10n.text('settings.theme.dark'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = AppSettingsScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('settings.title'))),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.text('settings.language.title')),
            subtitle: Text(settings.language.displayName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: Text(l10n.text('settings.theme.title')),
            subtitle: Text(_themeModeLabel(l10n, settings.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context),
          ),
          SwitchListTile(
            value: true,
            onChanged: null,
            title: Text(l10n.text('settings.localOnly.title')),
            subtitle: Text(l10n.text('settings.localOnly.subtitle')),
          ),
          ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: Text(l10n.text('settings.keepPreference.title')),
            subtitle: Text(l10n.text('settings.keepPreference.subtitle')),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: Text(l10n.text('settings.clearCache.title')),
            subtitle: Text(l10n.text('settings.clearCache.subtitle')),
          ),
        ],
      ),
    );
  }
}
