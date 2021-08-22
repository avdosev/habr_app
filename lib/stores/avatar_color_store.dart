import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:habr_app/models/author.dart';
import 'package:habr_app/styles/colors/default_avatar.dart';

class AvatarColorStore {
  AvatarColorStore();

  Color getColor(String authorAlias, Brightness brightness) {
    final colors = _getColorsByBrightness(brightness);
    return colors[authorAlias.hashCode.abs() % colors.length];
  }

  // ignore: missing_return
  List<Color> _getColorsByBrightness(Brightness brightness) {
    switch (brightness) {
      case Brightness.dark:
        return DefaultAvatarColors.darkValues;
      case Brightness.light:
        return DefaultAvatarColors.lightValues;
    }
  }
}
