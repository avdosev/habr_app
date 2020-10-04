import 'package:flutter/material.dart';

class HideFloatingActionButton extends StatelessWidget {
  final bool visible;
  final Widget child;
  final String tooltip;
  final VoidCallback onPressed;
  final Duration duration;

  HideFloatingActionButton({Key key,
    this.visible = true,
    this.child,
    this.onPressed,
    this.tooltip,
    @required
    this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(child: FadeTransition(child: child, opacity: animation), scale: animation);
        },
        child: Visibility(
            visible: visible,
            key: UniqueKey(),
            child: FloatingActionButton(
              tooltip: tooltip,
              child: child,
              onPressed: onPressed,
            )
        )
    );
  }

}