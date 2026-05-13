import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app_language.dart';
import 'translations/en.dart';
import 'translations/ja.dart';
import 'translations/zh.dart';

class AppLocalizations {
  AppLocalizations(this.language);

  final AppLanguage language;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('zh'),
    Locale('ja'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static Map<String, String> _messagesFor(AppLanguage language) {
    return switch (language) {
      AppLanguage.en => enMessages,
      AppLanguage.zh => zhMessages,
      AppLanguage.ja => jaMessages,
    };
  }

  String text(String key) {
    final messages = _messagesFor(language);
    return messages[key] ?? enMessages[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLanguage.values.any(
      (language) => language.locale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(
      AppLocalizations(AppLanguage.fromLocale(locale)),
    );
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
