import 'package:flutter/widgets.dart';

enum AppLanguage {
  en(Locale('en'), 'English'),
  zh(Locale('zh'), '中文'),
  ja(Locale('ja'), '日本語');

  const AppLanguage(this.locale, this.displayName);

  final Locale locale;
  final String displayName;

  static const fallback = AppLanguage.en;

  static AppLanguage fromLocale(Locale locale) {
    return AppLanguage.values.firstWhere(
      (language) => language.locale.languageCode == locale.languageCode,
      orElse: () => fallback,
    );
  }

  static AppLanguage fromLanguageCode(String? languageCode) {
    return AppLanguage.values.firstWhere(
      (language) => language.locale.languageCode == languageCode,
      orElse: () => fallback,
    );
  }
}
