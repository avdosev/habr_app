import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  textTheme: TextTheme(
      bodyText2: TextStyle(color: Colors.white70)
  ),
  accentColor: Colors.grey,
  primarySwatch: Colors.blueGrey,
  primaryColor: Colors.blueGrey[600],
  scaffoldBackgroundColor: const Color.fromRGBO(57, 57, 57, 1),
  colorScheme: ColorScheme.dark(secondary: Colors.grey),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);