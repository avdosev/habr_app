import 'package:flutter/material.dart';
import 'package:habr_app/widgets/dropdown_list_tile.dart';
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
          final int fontSize = box.get("FontSize", defaultValue: 16);
          final TextAlign textAlign = box.get('TextAlign', defaultValue: TextAlign.left);
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
                      title: const Text("Кастомизация"),
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
                        TextAlign.left: "Слева",
                        TextAlign.right: "Справа",
                        TextAlign.center: "По центру",
                        TextAlign.justify: "По ширине",
                      },
                      leading: const Icon(Icons.format_align_left),
                      title: Text("Выравнивание текста"),
                      defaultKey: textAlign,
                      onChanged: (val) {
                        box.put('TextAlign', val);
                      },
                    ),
                    /* TODO:
                    Icons:
                    format_line_spacing
                    format_indent_increase
                     */
                    ListTile(
                      title: Text("Межстрочный интервал"),
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
            ],
          );
        });
  }
}
