import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:habr_app/stores/app_settings.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppSettings()),
      ],
      builder: (context, widget) {
        final settings = context.watch<AppSettings>();
        final fontSize = settings.fontSize;
        final lineSpacing = settings.lineSpacing;
        return MaterialApp(
          title: 'Habr',
          theme:
              buildLightTheme(mainFontSize: fontSize, lineSpacing: lineSpacing),
          darkTheme:
              buildDarkTheme(mainFontSize: fontSize, lineSpacing: lineSpacing),
          themeMode: settings.themeMode,
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
