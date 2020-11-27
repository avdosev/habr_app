import 'package:flutter/material.dart';
import 'text_theme.dart';

ThemeData buildDarkTheme({
  double mainFontSize = 16,
}) {
  return ThemeData(
    textTheme: buildTextTheme(Colors.white70, mainFontSize),
    accentColor: Colors.grey,
    primarySwatch: Colors.blueGrey,
    primaryColor: Colors.blueGrey[600],
    scaffoldBackgroundColor: const Color.fromRGBO(57, 57, 57, 1),
    colorScheme:
        ColorScheme.dark(secondary: Colors.grey, primary: Colors.blueGrey),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.blueGrey[400],
    ),
    toggleableActiveColor: Colors.blueGrey[300],
  );
}
