import 'package:flutter/material.dart';
import 'package:habr_app/themes/text_theme.dart';

final lightTheme = ThemeData(
  textTheme: buildTextTheme(Colors.black87, 16),
  primarySwatch: Colors.blueGrey,
  primaryColor: Colors.blueGrey,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.blueGrey
  )
);