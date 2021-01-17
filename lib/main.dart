import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:habr_app/utils/hive_helper.dart';
import 'package:habr_app/styles/themes/themes.dart';
import 'package:habr_app/routing/routing.dart';


main() async {
  await initializeHive();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, settings, widget) {
        final fontSize = settings.get("FontSize", defaultValue: 16).toDouble();
        final lineSpacing = settings.get("LineSpacing", defaultValue: 1.35);
        return MaterialApp(
          title: 'Habr',
          theme: buildLightTheme(mainFontSize: fontSize, lineSpacing: lineSpacing),
          darkTheme: buildDarkTheme(mainFontSize: fontSize, lineSpacing: lineSpacing),
          themeMode: settings.get("ThemeMode", defaultValue: ThemeMode.system),
          supportedLocales: [
            const Locale('ru', ''),
            const Locale('en', ''),
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          routes: routes,
          initialRoute: "articles",
        );
      },
    );
  }
}
