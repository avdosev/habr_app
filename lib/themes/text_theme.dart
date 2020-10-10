import 'package:flutter/material.dart';

TextTheme buildTextTheme(Color color, double mainSize) {
  return TextTheme(
    headline1: TextStyle(color: color, fontSize: mainSize+6, fontWeight: FontWeight.w500),
    headline2: TextStyle(color: color, fontSize: mainSize+5, fontWeight: FontWeight.w500),
    headline3: TextStyle(color: color, fontSize: mainSize+4, fontWeight: FontWeight.w500),
    headline4: TextStyle(color: color, fontSize: mainSize+3, fontWeight: FontWeight.w500),
    headline5: TextStyle(color: color, fontSize: mainSize+2, fontWeight: FontWeight.w500),
    headline6: TextStyle(color: color, fontSize: mainSize, fontWeight: FontWeight.w500),
    bodyText2: TextStyle(color: color, fontSize: mainSize),
    subtitle1: TextStyle(color: color, fontSize: mainSize),
    subtitle2: TextStyle(color: color, fontSize: mainSize-2),
  );
}