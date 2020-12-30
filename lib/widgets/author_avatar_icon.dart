import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habr_app/widgets/picture.dart';
import '../habr/author_avatar_info.dart';
import 'package:habr_app/styles/colors/colors.dart';

class AuthorAvatarIcon extends StatelessWidget {
  final double height;
  final double width;
  final AuthorAvatarInfo avatar;

  AuthorAvatarIcon({this.avatar, this.height = 20, this.width = 20, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color colorForDefault = DefaultAvatarColors.lilac;
    Widget image;

    if (avatar.isDefault) {
      image = Container(
        decoration: BoxDecoration(
          // color: Colors.white,
          border: Border.all(color: colorForDefault),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: SvgPicture.asset(
          "assets/images/default_avatar.svg",
          color: colorForDefault,
          height: height,
          width: width,
        ),
      );
      // } else if (avatar.cached ?? false) {
    } else {
      if (avatar.cached) {
        image = Image.asset(
          avatar.url,
          height: height,
          width: width
        );
      } else {
        image = Image.network(
          avatar.url,
          height: height,
          width: width,
        );
      }
    }

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: image,
    );
  }
}
