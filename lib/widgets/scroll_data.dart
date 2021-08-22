import 'package:flutter/widgets.dart';

class ScrollData extends ScrollBehavior {
  final double? thinkness;
  final bool? isAlwaysShow;

  const ScrollData({this.thinkness, this.isAlwaysShow});

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    // When modifying this function, consider modifying the implementation in
    // the Material and Cupertino subclasses as well.
    switch (getPlatform(context)) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return RawScrollbar(
          thickness: thinkness,
          isAlwaysShown: isAlwaysShow,
          child: child,
          controller: details.controller,
        );
      default:
        return child;
    }
  }
}
