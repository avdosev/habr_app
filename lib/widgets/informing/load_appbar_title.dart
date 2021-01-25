import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoadAppBarTitle extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoadAppBarTitleState();
}

class _LoadAppBarTitleState extends State<LoadAppBarTitle>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  int alpha;
  bool direction;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    animation = Tween<double>(begin: 30, end: 85).animate(controller)
      ..addListener(() {
        setState(() {
          alpha = animation.value.round();
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (direction) {
            controller.forward();
          } else {
            controller.reverse();
          }
          direction = !direction;
        } else if (status == AnimationStatus.dismissed) {
          direction = false;
          controller.forward();
        }
      });
    alpha = 30;
    direction = false;
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryTextTheme.headline6.color;
    final loadingText = AppLocalizations.of(context).loading;
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: loadingText),
        TextSpan(
          text: '.',
          style: TextStyle(
            color: color.withAlpha(255 - (alpha.toDouble() * 1.1).round()),
          ),
        ),
        TextSpan(
          text: '.',
          style: TextStyle(
            color: color.withAlpha(255 - (alpha * 2)),
          ),
        ),
        TextSpan(
          text: '.',
          style: TextStyle(
            color: color.withAlpha(255 - (alpha * 3)),
          ),
        ),
      ]),
      overflow: TextOverflow.fade,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
