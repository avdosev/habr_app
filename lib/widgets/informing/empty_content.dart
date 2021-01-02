import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmptyContent extends StatelessWidget {
  final double pictureHeight;
  final double pictureWidth;

  EmptyContent({this.pictureHeight = 150, this.pictureWidth = 100});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/images/empty_comments.svg",
          height: pictureHeight, width: pictureWidth,
        ),
        const SizedBox(height: 40,),
        Text(AppLocalizations.of(context).emptyContent),
      ],
    );
  }
}