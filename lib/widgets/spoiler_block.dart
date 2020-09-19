import 'dart:math';
import 'package:flutter/material.dart';

class Spoiler extends StatefulWidget {
  final String title;
  final Widget child;

  Spoiler({this.title, this.child});

  @override
  State<StatefulWidget> createState() => _SpoilerState();
}

class _SpoilerState extends State<Spoiler> with TickerProviderStateMixin {
  bool visible = false;
  Animation _arrowAnimation;
  AnimationController _arrowAnimationController;

  @override
  initState() {
    super.initState();
    _arrowAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _arrowAnimation =
        Tween(begin: 0.0, end: pi/2).animate(_arrowAnimationController);
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
            child: Row(children: [
              AnimatedBuilder(
                animation: _arrowAnimationController,
                builder: (context, child) => Transform.rotate(
                    angle: _arrowAnimation.value,
                    child: Icon(Icons.arrow_right, color: themeData.primaryColor),
                )
              ),
              Text(widget.title,
                style: TextStyle(
                  color: themeData.primaryColor,
                  decorationColor: themeData.primaryColor,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dashed,
                ),
              ),
            ],),
            onTap: onTap,
          ),
          if (visible) SizedBox(height: 10,),
          if (visible) widget.child,
        ],
      )
    );
  }
}