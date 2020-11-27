import 'package:flutter/material.dart';
import 'package:habr_app/themes/text_theme.dart';

ThemeData buildLightTheme({
  double mainFontSize = 16,
  double lineSpacing = 1.35,
}) {
  return ThemeData(
      textTheme: buildTextTheme(Colors.black87, mainFontSize, lineSpacing),
      primarySwatch: Colors.blueGrey,
      primaryColor: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.blueGrey
      )
  );
}