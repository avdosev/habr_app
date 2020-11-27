import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DropDownTile<Key> extends StatelessWidget {
  final List<MapEntry<Key, String>> items;
  final Function(Key key) onChanged;
  final Key defaultKey;
  final Widget title;
  final Widget trailing;
  final Widget leading;

  DropDownTile({
    Map<Key, String> values,
    this.title,
    this.trailing,
    this.leading,
    this.defaultKey,
    this.onChanged,
  }) : items = values.entries.toList();

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      title: title,
      trailing: DropdownButton<Key>(
        value: defaultKey,
        onChanged: onChanged,
        items: items
            .map<DropdownMenuItem<Key>>((item) =>
                DropdownMenuItem<Key>(value: item.key, child: Text(item.value)))
            .toList(),
      ),
      leading: leading,
    ));
  }
}

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
