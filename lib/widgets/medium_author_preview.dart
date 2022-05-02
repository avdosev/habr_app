import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:habr_app/models/author.dart';
import 'package:habr_app/stores/avatar_color_store.dart';

import 'author_avatar_icon.dart';
import 'package:habr_app/widgets/link.dart';

class MediumAuthorPreview extends StatelessWidget {
  final Author author;

  MediumAuthorPreview(this.author);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final font = theme.textTheme.bodyText2!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: (font.height! - 1) * font.fontSize!),
          child: AuthorAvatarIcon(
            avatar: author.avatar,
            height: 40,
            width: 40,
            borderWidth: 1.5,
            defaultColor:
                AvatarColorStore().getColor(author.alias, theme.brightness),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            children: [
              Text.rich(
                TextSpan(children: [
                  if (author.fullName != null) ...[
                    TextSpan(text: author.fullName),
                    TextSpan(text: ', ')
                  ],
                  TextSpan(
                    children: [
                      TextSpan(text: '@'),
                      TextSpan(text: author.alias),
                    ],
                    style: TextStyle(color: linkColorFrom(context)),
                  ),
                ]),
                maxLines: 2,
                overflow: TextOverflow.fade,
              ),
              Text(author.speciality ?? AppLocalizations.of(context)!.user),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ],
    );
  }
}
