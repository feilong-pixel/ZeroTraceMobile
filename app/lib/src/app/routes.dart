import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/duplicates/duplicate_groups_screen.dart';
import '../features/review/review_screen.dart';
import '../features/scan/scan_screen.dart';
import '../features/settings/settings_screen.dart';

class AppRoutes {
  static const dashboard = '/';
  static const scan = '/scan';
  static const duplicates = '/duplicates';
  static const review = '/review';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      dashboard: (_) => const DashboardScreen(),
      scan: (_) => const ScanScreen(),
      duplicates: (_) => const DuplicateGroupsScreen(),
      review: (_) => const ReviewScreen(),
      settings: (_) => const SettingsScreen(),
    };
  }
}
