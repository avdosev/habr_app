import 'package:flutter/material.dart';

class CommentsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;

  CommentsButton({this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    final mainColor = color ?? Theme.of(context).colorScheme.secondary;
    return FlatButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(width: 2, color: mainColor)),
      padding: const EdgeInsets.all(15),
      onPressed: onPressed,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble, color: mainColor,),
            const SizedBox(width: 10,),
            Text("Комментарии", style: TextStyle(color: mainColor),),
          ]),
    );
  }

}