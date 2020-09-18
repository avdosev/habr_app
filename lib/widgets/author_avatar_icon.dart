import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../habr/image_info.dart' as image;
import '../habr/image_store.dart';

class AuthorAvatarIcon extends StatelessWidget {
  final double height;
  final double width;
  final image.ImageInfo avatar;
  get storeType => avatar.store;

  AuthorAvatarIcon({this.avatar, this.height = 20, this.width = 20});

  @override
  Widget build(BuildContext context) {
    Color colorForDefault = Colors.deepPurple;
    Widget image;
    switch (storeType) {
      case ImageStoreType.Network:
        if (avatar != null && avatar.url.length != 0) {
          image = Image.network(avatar.url, height: height, width: width,);
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
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: SvgPicture.asset(
            "assets/images/default_avatar.svg",
            color: colorForDefault, height: height, width: width,
          )
        );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: image,
    );
  }
}
