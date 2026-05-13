import 'package:flutter/material.dart';

import '../../shared/i18n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('settings.title'))),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.text('settings.language.title')),
            subtitle: Text(l10n.text('settings.language.subtitle')),
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
