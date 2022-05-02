import 'dart:math';
import 'package:flutter/material.dart';
import 'package:habr_app/widgets/link.dart';

class Spoiler extends StatefulWidget {
  final String? title;
  final Widget? child;

  Spoiler({this.title, this.child});

  @override
  State<StatefulWidget> createState() => _SpoilerState();
}

class _SpoilerState extends State<Spoiler> with TickerProviderStateMixin {
  late bool visible;
  late Animation _arrowAnimation;
  late AnimationController _arrowAnimationController;
  static const duration = Duration(milliseconds: 100);

  @override
  initState() {
    super.initState();
    visible = false;
    _arrowAnimationController =
        AnimationController(vsync: this, duration: duration);
    _arrowAnimation =
        Tween(begin: 0.0, end: pi / 2).animate(_arrowAnimationController);
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    super.dispose();
  }

  onTap() {
    setState(() {
      visible
          ? _arrowAnimationController.reverse()
          : _arrowAnimationController.forward();
      visible = !visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _arrowAnimationController,
                builder: (context, child) => Transform.rotate(
                    angle: _arrowAnimation.value, child: child),
                child: Icon(Icons.arrow_right, color: linkColorFrom(context)),
              ),
              Expanded(
                  child: Text(
                widget.title!,
                style: TextStyle(
                  color: linkColorFrom(context),
                  decorationColor: linkColorFrom(context),
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dashed,
                ),
              ))
            ],
          ),
          onTap: onTap,
        ),
        SizeTransition(
          sizeFactor: Tween<double>(begin: 0, end: 1)
              .animate(_arrowAnimationController),
          axisAlignment: -1.0,
          child: Column(children: [
            const SizedBox(height: 10),
            widget.child!,
          ]),
        )
      ],
    ));
  }
}
