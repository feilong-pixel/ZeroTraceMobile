import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/sync/phone_sync_screen.dart';

class AppRoutes {
  static const dashboard = '/';
  static const settings = '/settings';
  static const phoneSync = '/phone-sync';

  static Map<String, WidgetBuilder> get routes {
    return {
      dashboard: (_) => const DashboardScreen(),
      settings: (_) => const SettingsScreen(),
      phoneSync: (_) => const PhoneSyncScreen(),
    };
  }
}
