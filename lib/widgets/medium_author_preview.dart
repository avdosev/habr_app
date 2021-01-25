import 'package:flutter/material.dart';

import 'package:habr_app/models/author.dart';
import 'package:habr_app/stores/avatar_color_store.dart';

import 'author_avatar_icon.dart';

class MediumAuthorPreview extends StatelessWidget {
  final Author author;

  MediumAuthorPreview(this.author);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        AuthorAvatarIcon(
          avatar: author.avatar,
          height: 40,
          width: 40,
          borderWidth: 1.5,
          defaultColor: AvatarColorStore().getColor(author, theme.brightness),
        ),
        SizedBox(width: 15),
        Column(
          children: [
            Text.rich(TextSpan(children: [
              if (author.fullName != null) ...[
                TextSpan(text: author.fullName),
                TextSpan(text: ', ')
              ],
              TextSpan(
                children: [
                  TextSpan(text: '@'),
                  TextSpan(text: author.alias),
                ],
                style: TextStyle(color: theme.primaryColor),
              ),
            ]), overflow: TextOverflow.fade,),
            Text(author.speciality),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ],
    );
  }
}