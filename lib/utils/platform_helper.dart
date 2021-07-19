import 'package:flutter/material.dart';

bool isDesktop(BuildContext context) {
  final platform = Theme.of(context).platform;
  switch (platform) {
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return true;
    default:
      return false;
  }
}
