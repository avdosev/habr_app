import 'package:flutter/material.dart';

class WrappedContainer extends StatelessWidget {
  final List<Widget> children;

  WrappedContainer({this.children});

  @override
  Widget build(BuildContext context) {
    final wrappedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      wrappedChildren.add(children[i]);
      if (i != children.length - 1) wrappedChildren.add(const SizedBox(height: 20));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: wrappedChildren,
    );
  }
}