import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:habr_app/hive/adaptors.dart';
import 'pages/pages.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ThemeAdapter());
  await Hive.openBox('settings');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, settings, widget) {
        return MaterialApp(
          title: 'Habr',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            primaryColor: Colors.blueGrey,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData(
            textTheme: TextTheme(
                bodyText2: TextStyle(color: Colors.white70)
            ),
            accentColor: Colors.grey,
            primarySwatch: Colors.blueGrey,
            primaryColor: Colors.blueGrey[600],
            scaffoldBackgroundColor: const Color.fromRGBO(57, 57, 57, 1),
            colorScheme: ColorScheme.dark(secondary: Colors.grey),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          themeMode: settings.get("ThemeMode", defaultValue: ThemeMode.system),
          supportedLocales: [
            const Locale('ru'),
            const Locale('en'),
          ],
          localizationsDelegates: [
            // ... app-specific localization delegate[s] here
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          routes: {
            "settings": (BuildContext context) => SettingsPage(),
            "articles": (BuildContext context) => ArticlesList(),
          },
          initialRoute: "articles",
        );
      }
    );
  }
}
