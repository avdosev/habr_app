import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:habr_app/stores/app_settings.dart';
import 'package:habr_app/utils/workers/hasher.dart';
import 'package:habr_app/utils/workers/image_loader.dart';
import 'package:provider/provider.dart';

import 'package:habr_app/utils/hive_helper.dart';
import 'package:habr_app/styles/themes/themes.dart';
import 'package:habr_app/routing/routing.dart';

import 'habr/api.dart';
import 'habr_storage/image_storage.dart';

void main() async {
  await initializeHive();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => Habr()),
        Provider(
            create: (_) => ImageLocalStorage(
                hashComputer: MD5Hash(), imageLoader: ImageHttpLoader())),
        Provider(create: (context) {
          final api = Provider.of<Habr>(context, listen: false);
          final imageStore =
              Provider.of<ImageLocalStorage>(context, listen: false);
          return HabrStorage(api: api, imgStore: imageStore);
        }),
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
          supportedLocales: const [
            Locale('ru', ''),
            Locale('en', ''),
          ],
          localizationsDelegates: const [
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
