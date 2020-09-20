import 'package:flutter/material.dart';

class UnorderedList extends StatelessWidget {
  final List<Widget> children;
  UnorderedList({this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map<Widget>((child) =>
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
          Container(child: const Bullet(), padding: const EdgeInsets.only(right: 10, top: 5),),
          Expanded(child: child)
        ],)
      ).toList(),
    );
  }
}

class Bullet extends StatelessWidget{
  final double height;
  final double width;
  final Color color;
  const Bullet({
    this.height = 5,
    this.width = 5,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}