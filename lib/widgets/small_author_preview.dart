import 'package:flutter/material.dart';

import 'package:habr_app/models/author.dart';
import 'package:habr_app/stores/avatar_color_store.dart';

import 'author_avatar_icon.dart';

class SmallAuthorPreview extends StatelessWidget {
  final Author author;
  final TextStyle? textStyle;

  SmallAuthorPreview(this.author, {this.textStyle});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AuthorAvatarIcon(
          key: ValueKey('avatar_${author.avatar.hashCode}'),
          avatar: author.avatar,
          defaultColor:
              AvatarColorStore().getColor(author.alias, themeData.brightness),
        ),
        SizedBox(
          width: 5,
        ),
        Text(author.alias, style: textStyle),
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }
}
