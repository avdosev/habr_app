import 'package:flutter/material.dart';
import 'package:habr_app/widgets/dropdown_list_tile.dart';
import 'package:habr_app/widgets/html_elements/highlight_code.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).settings),
        ),
        body: Settings());
  }
}

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Hive.box('settings');
    return ValueListenableBuilder(
        valueListenable: settings.listenable(),
        builder: (context, Box<dynamic> box, widget) {
          final localizations = AppLocalizations.of(context);
          final themeMode =
              box.get("ThemeMode", defaultValue: ThemeMode.system);
          final codeThemeMode =
              box.get("CodeThemeMode", defaultValue: ThemeMode.dark);
          final lightCodeTheme = box.get('LightCodeTheme', defaultValue: 'github');
          final darkCodeTheme = box.get('DarkCodeTheme', defaultValue: 'androidstudio');
          final int fontSize = box.get("FontSize", defaultValue: 16);
          final TextAlign textAlignArticle = box.get('TextAlignArticle', defaultValue: TextAlign.left);
          final TextAlign textAlignComments = box.get('TextAlignComments', defaultValue: TextAlign.left);
          final double lineSpacing = box.get('LineSpacing', defaultValue: 1.35);

          return ListView(
            children: [
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(localizations.systemTheme),
                      secondary: const Icon(Icons.brightness_auto),
                      value: themeMode == ThemeMode.system,
                      onChanged: (val) {
                        if (val) {
                          box.put('ThemeMode', ThemeMode.system);
                        } else {
                          box.put('ThemeMode', ThemeMode.light);
                        }
                      },
                    ),
                    SwitchListTile(
                      title: Text(localizations.darkTheme),
                      secondary: const Icon(Icons.brightness_2),
                      value: themeMode == ThemeMode.dark,
                      onChanged: themeMode != ThemeMode.system
                          ? (val) {
                              if (val) {
                                box.put('ThemeMode', ThemeMode.dark);
                              } else {
                                box.put('ThemeMode', ThemeMode.light);
                              }
                            }
                          : null, // Switch будет неактивен при Null
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: Text(AppLocalizations.of(context).customization),
                    ),
                    ListTile(
                      // leading: const Icon(Icons.font_download_outlined),
                      title: Text(localizations.fontSize),
                      subtitle: Row(
                        children: [
                          const Icon(Icons.format_size, size: 15),
                          Expanded(
                            child: Slider(
                              min: 12,
                              max: 23,
                              divisions: 23 - 12,
                              value: fontSize.toDouble(),
                              onChanged: (value) {
                                box.put('FontSize', value.round());
                              },
                              label: fontSize.toString(),
                              semanticFormatterCallback: (value) =>
                                  value.round().toString(),
                            ),
                          ),
                          const Icon(Icons.format_size),
                        ],
                      ),
                    ),
                    DropDownListTile(
                      values: {
                        TextAlign.left: AppLocalizations.of(context).left,
                        TextAlign.right: AppLocalizations.of(context).right,
                        TextAlign.center: AppLocalizations.of(context).center,
                        TextAlign.justify: AppLocalizations.of(context).fullWidth,
                      },
                      leading: const Icon(Icons.format_align_left),
                      title: Text("Выравнивание текста в постах"),
                      defaultKey: textAlignArticle,
                      onChanged: (val) {
                        box.put('TextAlignArticle', val);
                      },
                    ),
                    DropDownListTile(
                      values: {
                        TextAlign.left: AppLocalizations.of(context).left,
                        TextAlign.right: AppLocalizations.of(context).right,
                        TextAlign.center: AppLocalizations.of(context).center,
                        TextAlign.justify: AppLocalizations.of(context).fullWidth,
                      },
                      leading: const Icon(Icons.format_align_left),
                      title: Text("Выравнивание текста в комментариях"),
                      defaultKey: textAlignComments,
                      onChanged: (val) {
                        box.put('TextAlignComments', val);
                      },
                    ),
                    /* TODO:
                    Icons:
                    format_line_spacing
                    format_indent_increase
                     */
                    ListTile(
                      title: Text(AppLocalizations.of(context).lineSpacing),
                      subtitle: Row(
                        children: [
                          const Icon(Icons.format_line_spacing, size: 15),
                          Expanded(
                            child: Slider(
                              min: 1,
                              max: 2,
                              divisions: 20,
                              value: lineSpacing,
                              onChanged: (value) {
                                box.put('LineSpacing', value);
                              },
                              label: lineSpacing.toString(),
                              semanticFormatterCallback: (value) =>
                                  lineSpacing.toString(),
                            ),
                          ),
                          const Icon(Icons.format_line_spacing),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: Text(AppLocalizations.of(context).customizationCode),
                    ),
                    SwitchListTile(
                      title: Text(localizations.systemTheme),
                      secondary: const Icon(Icons.brightness_auto),
                      value: codeThemeMode == ThemeMode.system,
                      onChanged: (val) {
                        if (val) {
                          box.put('CodeThemeMode', ThemeMode.system);
                        } else {
                          box.put('CodeThemeMode', ThemeMode.dark);
                        }
                      },
                    ),
                    SwitchListTile(
                      title: Text(localizations.darkTheme),
                      secondary: const Icon(Icons.brightness_2),
                      value: codeThemeMode == ThemeMode.dark,
                      onChanged: codeThemeMode != ThemeMode.system
                          ? (val) {
                        if (val) {
                          box.put('CodeThemeMode', ThemeMode.dark);
                        } else {
                          box.put('CodeThemeMode', ThemeMode.light);
                        }
                      }
                          : null, // Switch будет неактивен при Null
                    ),
                    DropDownListTile(
                      values: Map.fromIterables(HighlightCode.themes, HighlightCode.themes),
                      title: Text("Стиль темной темы"),
                      defaultKey: darkCodeTheme,
                      onChanged: (val) {
                        box.put('DarkCodeTheme', val);
                      },
                    ),
                    DropDownListTile(
                      values: Map.fromIterables(HighlightCode.themes, HighlightCode.themes),
                      title: Text("Стиль светлой темы"),
                      defaultKey: lightCodeTheme,
                      onChanged: (val) {
                        box.put('LightCodeTheme', val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
