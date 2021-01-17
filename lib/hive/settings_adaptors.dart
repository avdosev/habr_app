import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class ThemeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final typeId = 0;

  @override
  ThemeMode read(BinaryReader reader) {
    return ThemeMode.values[int.parse(reader.read())];
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    writer.write(obj.index.toString());
  }
}

class TextAlignAdapter extends TypeAdapter<TextAlign> {
  @override
  final typeId = 1;

  @override
  TextAlign read(BinaryReader reader) {
    return TextAlign.values[int.parse(reader.read())];
  }

  @override
  void write(BinaryWriter writer, TextAlign obj) {
    writer.write(obj.index.toString());
  }
}