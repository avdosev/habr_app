import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

enum ImageStoreType {
  Cached,
  Network,
  Default
}

class AuthorAvatarIcon extends StatelessWidget {
  final double height;
  final double width;
  final String avatarUrl;
  final ImageStoreType storeType;

  AuthorAvatarIcon({this.avatarUrl, this.storeType, this.height = 20, this.width = 20});

  @override
  Widget build(BuildContext context) {
    Color colorForDefault = Colors.deepPurple;
    Widget image;
    switch (storeType) {
      case ImageStoreType.Network:
        if (avatarUrl != null && avatarUrl.length != 0) {
          image = Image.network(avatarUrl, height: height, width: width,);
          break;
        }
        continue default_icon;

      case ImageStoreType.Cached:
        throw UnimplementedError("Cached images not supported"); // TODO: support cache
      default_icon:
      default:
        image = Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorForDefault),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: SvgPicture.asset(
            "assets/images/default_avatar.svg",
            color: colorForDefault, height: height, width: width,
          )
        );
    }

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      child: image,
    );
  }
}
