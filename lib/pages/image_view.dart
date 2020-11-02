import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';

class HeroPhotoViewRouteWrapper extends StatelessWidget {
  const HeroPhotoViewRouteWrapper({
    this.imageProvider,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    @required this.tag,
  });

  final ImageProvider imageProvider;
  final Decoration backgroundDecoration;
  final String tag;
  final dynamic minScale;
  final dynamic maxScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(
        imageProvider: imageProvider,
        backgroundDecoration: backgroundDecoration,
        minScale: minScale,
        maxScale: maxScale,
        heroAttributes: PhotoViewHeroAttributes(tag: tag),
      ),
    );
  }
}