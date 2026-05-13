import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'routes.dart';
import 'theme.dart';
import '../shared/i18n/app_language.dart';
import '../shared/i18n/app_localizations.dart';

class ZeroTraceMobileApp extends StatelessWidget {
  const ZeroTraceMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZeroTraceMobile',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: AppLanguage.fallback.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      initialRoute: AppRoutes.dashboard,
      routes: AppRoutes.routes,
    );
  }
}
