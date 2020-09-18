import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/articles_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
      themeMode: ThemeMode.system,
      home: ArticlesList(),
      supportedLocales: [
        const Locale('ru'),
        const Locale('en'),
      ],
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
