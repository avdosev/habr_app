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

  DropDownTile({Map<Key, String> values,
    this.title,
    this.trailing,
    this.leading,
    this.defaultKey,
    this.onChanged,
  }) :
    items = values.entries.toList();

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(
      title: title,
      trailing: DropdownButton<Key>(
        value: defaultKey,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<Key>>(
            (item) =>
                DropdownMenuItem<Key>(
                  value: item.key,
                  child: Text(item.value)
                )
        ).toList(),
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
        body: Settings()
    );
  }
}

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Hive.box('settings');
    return ValueListenableBuilder(
      valueListenable: settings.listenable(),
      builder: (context, box, widget) =>
          ListView(
            children: [
              // SwitchListTile(
              //   value: true,
              //   onChanged: (val) => print(val),
              // ),
              DropDownTile<ThemeMode>(
                values: <ThemeMode, String>{
                  ThemeMode.system: "System",
                  ThemeMode.light: "Light",
                  ThemeMode.dark: "Dark",
                },
                defaultKey: box.get("ThemeMode", defaultValue: ThemeMode.system),
                title: Text("Theme"),
                leading: const Icon(Icons.brightness_2),
                onChanged: (ThemeMode mode) {
                  box.put('ThemeMode', mode);
                },
              )
            ],
        )
    );
  }

}