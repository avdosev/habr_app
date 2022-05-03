import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:habr_app/models/author_avatar_info.dart';
import 'package:habr_app/styles/colors/colors.dart';

class AuthorAvatarIcon extends StatelessWidget {
  final double height;
  final double width;
  final double borderWidth;
  final double radius;
  final AuthorAvatarInfo? avatar;
  final Color? defaultColor;

  AuthorAvatarIcon({
    required this.avatar,
    this.height = 20,
    this.width = 20,
    this.defaultColor,
    this.borderWidth = 1.0,
    this.radius = 5,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color colorForDefault = defaultColor ?? DefaultAvatarColors.lilac;
    Widget image;

    if (avatar!.isDefault) {
      image = Container(
        decoration: BoxDecoration(
          // color: Colors.white,
          border: Border.all(color: colorForDefault, width: borderWidth),
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
        child: SvgPicture.asset(
          "assets/images/default_avatar.svg",
          color: colorForDefault,
          height: height,
          width: width,
        ),
      );
    } else {
      if (avatar!.cached) {
        image = Image.file(File(avatar!.url!), height: height, width: width);
      } else {
        image = CachedNetworkImage(
          imageUrl: avatar!.url!,
          height: height,
          width: width,
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: image,
    );
  }
}
