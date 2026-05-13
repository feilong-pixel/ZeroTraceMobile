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
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.scan),
            icon: const Icon(Icons.search_outlined),
            label: Text(l10n.text('dashboard.startScan')),
          ),
          const SizedBox(height: 16),
          _DashboardTile(
            title: l10n.text('dashboard.duplicatePhotos.title'),
            value: l10n.text('dashboard.duplicatePhotos.value'),
            icon: Icons.filter_none_outlined,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.duplicates),
          ),
          const SizedBox(height: 8),
          _DashboardTile(
            title: l10n.text('dashboard.similarImages.title'),
            value: l10n.text('dashboard.similarImages.value'),
            icon: Icons.compare_outlined,
          ),
          const SizedBox(height: 8),
          _DashboardTile(
            title: l10n.text('dashboard.cleanupSafety.title'),
            value: l10n.text('dashboard.cleanupSafety.value'),
            icon: Icons.verified_user_outlined,
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
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}
