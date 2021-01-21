import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppSettings {
  final data = Hive.box('settings');

  TextAlign get articleTextAlign => data.get('TextAlignArticle', defaultValue: TextAlign.left);
  TextAlign get commentTextAlign => data.get('TextAlignComments', defaultValue: TextAlign.left);
}