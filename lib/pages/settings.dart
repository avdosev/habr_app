import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
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
          final themeMode =
              box.get("ThemeMode", defaultValue: ThemeMode.system);
          int fontSize = box.get("FontSize", defaultValue: 16);

          return ListView(
            children: [
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text("System Theme"),
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
                      title: const Text("Dark Theme"),
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
                      title: Text("Размер текста"),
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
                    /* TODO:
                    Icons:
                    format_line_spacing
                    format_indent_increase
                     */
                  ],
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.filter_alt),
                  title: const Text("Фильтры"),
                  onTap: () {
                    // TODO: changing filters
                  },
                ),
              )
            ],
          );
        });
  }
}
