import 'package:flutter/material.dart';

class MaterialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  final IconData iconData;
  final String text;

  MaterialButton({this.onPressed, this.color, this.iconData, this.text});

  @override
  Widget build(BuildContext context) {
    final mainColor = color ?? Theme.of(context).colorScheme.secondary;
    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.all(15)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(width: 2, color: mainColor)),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: mainColor,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: TextStyle(color: mainColor),
          ),
        ],
      ),
    );
  }
}

class CommentsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;

  CommentsButton({this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        onPressed: onPressed,
        color: color,
        iconData: Icons.chat_bubble,
        text: "Комментарии");
  }
}

class SearchButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;

  SearchButton({this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        onPressed: onPressed,
        color: color,
        iconData: Icons.search,
        text: "Поиск");
  }
}
