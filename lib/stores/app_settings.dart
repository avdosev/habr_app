import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppSettings extends ChangeNotifier {
  final data = Hive.box('settings');

  AppSettings() {
    data.watch().listen((event) {
      notifyListeners();
    });
  }

  TextAlign get articleTextAlign =>
      data.get('TextAlignArticle', defaultValue: TextAlign.left);
  set articleTextAlign(TextAlign align) => data.put('TextAlignArticle', align);
  TextAlign get commentTextAlign =>
      data.get('TextAlignComments', defaultValue: TextAlign.left);
  set commentTextAlign(TextAlign align) => data.put('TextAlignComments', align);

  ThemeMode get themeMode =>
      data.get("ThemeMode", defaultValue: ThemeMode.system);

  set themeMode(ThemeMode mode) => data.put('ThemeMode', mode);

  ThemeMode get codeThemeMode =>
      data.get('CodeThemeMode', defaultValue: ThemeMode.dark);
  set codeThemeMode(ThemeMode mode) => data.put('CodeThemeMode', mode);

  String get lightCodeTheme =>
      data.get('LightCodeTheme', defaultValue: 'github');
  set lightCodeTheme(String theme) => data.put('LightCodeTheme', theme);

  String get darkCodeTheme =>
      data.get('DarkCodeTheme', defaultValue: 'androidstudio');
  set darkCodeTheme(String theme) => data.put('DarkCodeTheme', theme);

  double get fontSize => data.get("FontSize", defaultValue: 16.0);
  set fontSize(double size) => data.put("FontSize", size);

  double get lineSpacing => data.get("LineSpacing", defaultValue: 1.35);
  set lineSpacing(double val) => data.put("LineSpacing", val);
}
