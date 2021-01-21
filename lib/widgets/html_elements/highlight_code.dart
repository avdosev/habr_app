import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/theme_map.dart';

class HighlightCode extends StatelessWidget {
  final String text;
  final String language;
  final EdgeInsets padding;
  final TextStyle codeStyle;
  final ThemeMode themeMode;
  final String themeNameDark;
  final String themeNameLight;

  HighlightCode(
    this.text, {
    this.language,
    this.padding,
    this.codeStyle,
    this.themeMode,
    this.themeNameDark = "androidstudio",
    this.themeNameLight = "github",
  });

  Widget build(BuildContext context) {
    final mode = _getThemeMode(context);

    Map<String, TextStyle> theme;
    if (mode == ThemeMode.dark) {
      theme = themeMap[themeNameDark];
    } else {
      theme = themeMap[themeNameLight];
    }

    return HighlightView(
      // The original code to be highlighted
      text,
      // Specify language
      // It is recommended to give it a value for performance
      language: language ?? "",
      padding: padding,

      // Specify highlight theme
      // All available themes are listed in `themes` folder
      theme: theme,

      // Specify text style
      textStyle: codeStyle ??
          const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
          ),
    );
  }

  ThemeMode _getThemeMode(BuildContext context) {
    var mode = themeMode;
    if (mode == null || mode == ThemeMode.system) {
      switch (Theme.of(context).brightness) {
        case Brightness.dark:
          mode = ThemeMode.dark;
          break;
        case Brightness.light:
          mode = ThemeMode.light;
          break;
      }
    }
    return mode;
  }

  static List<String> themes = themeMap.keys.toList();
}
