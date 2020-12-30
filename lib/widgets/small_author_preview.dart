import 'package:flutter/material.dart';
import 'package:habr_app/habr/habr.dart';
import '../habr/author_avatar_info.dart';

import 'author_avatar_icon.dart';

class SmallAuthorPreview extends StatelessWidget {
  final Author author;
  SmallAuthorPreview(this.author);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AuthorAvatarIcon(avatar: author.avatar, key: ValueKey('avatar_${author.avatar.hashCode}'),),
        SizedBox(width: 5,),
        Text(author.alias, style: TextStyle(fontSize: 15)),
      ]
    );
  }

}