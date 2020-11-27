import 'package:flutter/material.dart';

class DropDownListTile<Key> extends StatelessWidget {
  final List<MapEntry<Key, String>> items;
  final Function(Key key) onChanged;
  final Key defaultKey;
  final Widget title;
  final Widget trailing;
  final Widget leading;

  DropDownListTile({
    @required Map<Key, String> values,
    @required this.title,
    this.trailing,
    this.leading,
    @required this.defaultKey,
    @required this.onChanged,
  }) : items = values.entries.toList();

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
    );
  }
}
