import 'package:flutter/widgets.dart';

import '../shared/i18n/app_language.dart';

class AppSettingsScope extends InheritedWidget {
  const AppSettingsScope({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    required super.child,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  static AppSettingsScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope was not found in the widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppSettingsScope oldWidget) {
    return language != oldWidget.language ||
        onLanguageChanged != oldWidget.onLanguageChanged;
  }
}
