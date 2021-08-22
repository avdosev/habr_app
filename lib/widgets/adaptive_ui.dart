import 'package:flutter/material.dart';

class CenterAdaptiveConstrait extends StatelessWidget {
  final Widget child;

  const CenterAdaptiveConstrait({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 880),
        child: child,
      ),
    );
  }
}

class DefaultConstraints extends StatelessWidget {
  final Widget child;

  const DefaultConstraints({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 880,
        child: child,
      ),
    );
  }
}
