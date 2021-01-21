import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppSettings {
  final data = Hive.box('settings');

  TextAlign get articleTextAlign => data.get('TextAlignArticle', defaultValue: TextAlign.left);
  TextAlign get commentTextAlign => data.get('TextAlignComments', defaultValue: TextAlign.left);

  ThemeMode get codeThemeMode => data.get('CodeThemeMode', defaultValue: ThemeMode.dark);

  String get lightCodeTheme => data.get('LightCodeTheme', defaultValue: 'github');
  String get darkCodeTheme => data.get('DarkCodeTheme', defaultValue: 'androidstudio');
}