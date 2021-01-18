import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:habr_app/utils/log.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:habr_app/pages/image_view.dart';

class Picture extends StatelessWidget {
  final String url;
  final bool clickable;
  final double height;
  final double width;

  Picture.network(this.url,
      {this.clickable = false, this.height, this.width, Key key})
      : super(key: key);

  // TODO: make asset constructor
  // Picture.asset(
  //   String assetName, {
  //   double height,
  //
  // }) :
  //       image = url.endsWith("svg") ? SvgPicture.asset(assetName)

  @override
  Widget build(BuildContext context) {
    Widget image;
    final textTheme = Theme.of(context).textTheme.bodyText2;

    if (url.endsWith("svg")) {
      image = Center(child: Transform.scale(
        scale: 2,
        alignment: Alignment.center,
        child: SvgPicture.network(url, color: textTheme.color),
      ));
    } else {
      image = Container(
        height: height,
        width: width,
        child: LoadBuilder(
          future: HabrStorage().imgStore.getImage(url),
          onRightBuilder: (context, filePath) {
            Widget widget = Image.file(
              File(filePath),
              height: height,
              width: width,
            );
            if (clickable) {
              widget = _buildClickableImage(
                  context, widget, FileImage(File(filePath)));
            }
            return widget;
          },
          onErrorBuilder: (context, err) {
            Widget widget = Image.network(
              url,
              height: height,
              width: width,
            );
            if (clickable) {
              widget = _buildClickableImage(context, widget, NetworkImage(url));
            }
            return widget;
          },
        ),
      );
    }
    return image;
  }

  _buildClickableImage(
      BuildContext context, Widget child, ImageProvider imgProvider) {
    final heroTag = url;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HeroPhotoViewRouteWrapper(
              tag: heroTag,
              imageProvider: imgProvider,
            ),
          ),
        );
      },
      child: Container(
        child: Hero(
          tag: heroTag,
          child: child,
        ),
      ),
    );
  }
}
