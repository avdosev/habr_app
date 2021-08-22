import 'package:flutter/material.dart';

class UnorderedList extends StatelessWidget {
  final List<Widget> children;
  UnorderedList({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map<Widget>(
            (child) => UnorderedItem(child: child),
          )
          .toList(),
    );
  }
}

class UnorderedItem extends StatelessWidget {
  final Widget child;

  UnorderedItem({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme.bodyText2!;
    final bulletSize = 5;
    final centerBaseline =
        (theme.fontSize! * theme.height! - bulletSize / 2) / 2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          child: const Bullet(),
          padding: EdgeInsets.only(right: 10, top: centerBaseline),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class Bullet extends StatelessWidget {
  final double height;
  final double width;
  final Color? color;
  const Bullet({this.height = 5, this.width = 5, this.color});

  @override
  Widget build(BuildContext context) {
    final bulletColor = color ?? Theme.of(context).iconTheme.color;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: bulletColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
