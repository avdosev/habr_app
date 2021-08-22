import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppSettings extends ChangeNotifier {
  final data = Hive.box('settings');

  AppSettings() {
    data.watch().listen((event) {
      notifyListeners();
    });
    if (timeThemeSwitcher) {
      changeThemeByTime();
    }
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

  bool get timeThemeSwitcher =>
      data.get('TimeThemeSwitcher', defaultValue: false);
  set timeThemeSwitcher(bool val) => data
      .put('TimeThemeSwitcher', val)
      .whenComplete(() => changeThemeByTime());

  TimeOfDay get fromTimeThemeSwitch => data.get('FromTimeThemeSwitch',
      defaultValue: TimeOfDay(hour: 0, minute: 0));
  set fromTimeThemeSwitch(TimeOfDay val) => data
      .put('FromTimeThemeSwitch', val)
      .whenComplete(() => changeThemeByTime());

  TimeOfDay get toTimeThemeSwitch => data.get('ToTimeThemeSwitch',
      defaultValue: TimeOfDay(hour: 0, minute: 0));
  set toTimeThemeSwitch(TimeOfDay val) => data
      .put('ToTimeThemeSwitch', val)
      .whenComplete(() => changeThemeByTime());

  bool get showPreviewText => data.get('ShowPreviewText', defaultValue: false);
  set showPreviewText(bool val) => data.put('ShowPreviewText', val);

  static bool needSetLightTheme(
      TimeOfDay current, TimeOfDay from, TimeOfDay to) {
    final timeLower = (TimeOfDay d1, TimeOfDay d2) =>
        d1.hour < d2.hour || (d1.hour == d2.hour && d1.minute <= d2.minute);
    final timeHigherOrEqual = (TimeOfDay d1, TimeOfDay d2) =>
        d1.hour > d2.hour || (d1.hour == d2.hour && d1.minute >= d2.minute);
    if (timeHigherOrEqual(to, from)) {
      return timeHigherOrEqual(current, from) && timeLower(current, to);
    } else {
      return timeHigherOrEqual(current, from) || timeLower(current, to);
    }
  }

  void changeThemeByTime() {
    if (!timeThemeSwitcher) return;
    if (needSetLightTheme(
      TimeOfDay.now(),
      fromTimeThemeSwitch,
      toTimeThemeSwitch,
    )) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }
  }
}
