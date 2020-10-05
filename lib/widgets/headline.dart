import 'package:flutter/material.dart';

enum HeadLineType {
  h1, h2, h3, h4, h5, h6
}

class HeadLine extends StatelessWidget {
  final String text;
  final HeadLineType type;
  const HeadLine({this.text, this.type});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textStyle = {
      HeadLineType.h1: textTheme.headline1,
      HeadLineType.h2: textTheme.headline2,
      HeadLineType.h3: textTheme.headline3,
      HeadLineType.h4: textTheme.headline4,
      HeadLineType.h5: textTheme.headline5,
      HeadLineType.h6: textTheme.headline6,
    }[HeadLineType.h6];
    return Text(text, style: textStyle);
  }
}