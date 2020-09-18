import 'dividing_block.dart';
import 'package:flutter/material.dart';

class Spoiler extends StatelessWidget {
  final String title;
  final List<Widget> children;

  Spoiler({this.title, this.children});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return WrappedContainer(
      children: [
        Text(title,
          style: TextStyle(
            color: themeData.primaryColor,
            decorationColor: themeData.primaryColor,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dashed,
          ),
        ),
        ...children // TODO: stealthy children
      ],
    );
  }
}