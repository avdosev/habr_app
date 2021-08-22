import 'package:flutter/material.dart';

class WrappedContainer extends StatelessWidget {
  final List<Widget> children;
  final double distance;

  WrappedContainer({required this.children, this.distance = 20});

  @override
  Widget build(BuildContext context) {
    final wrappedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      wrappedChildren.add(children[i]);
      if (i != children.length - 1)
        wrappedChildren.add(SizedBox(height: distance));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: wrappedChildren,
    );
  }
}
