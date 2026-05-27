import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../shared/i18n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.text('app.title')),
        actions: [
          IconButton(
            tooltip: l10n.text('nav.settings'),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.text('dashboard.tagline'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.phoneSync),
            icon: const Icon(Icons.wifi_tethering_outlined),
            label: Text(l10n.text('dashboard.phoneSync')),
          ),
          const SizedBox(height: 16),
          _DashboardTile(
            title: l10n.text('dashboard.similarImages.title'),
            value: l10n.text('dashboard.similarImages.value'),
            icon: Icons.compare_outlined,
          ),
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
