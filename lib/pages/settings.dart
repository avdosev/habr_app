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
        builder: (context, box, widget) {
          final themeMode =
              box.get("ThemeMode", defaultValue: ThemeMode.system);

          return ListView(
            children: [
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text("System Theme"),
                      secondary: const Icon(Icons.brightness_6),
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
              )
            ],
          );
        });
  }
}
