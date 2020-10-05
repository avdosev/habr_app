import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Picture extends StatelessWidget {
  final Widget image;

  Picture.network(String url) :
      image = url.endsWith("svg") ? SvgPicture.network(url) : Image.network(url)
  ;

  // TODO: make asset constructor
  // Picture.asset(
  //   String assetName, {
  //   double height,
  //
  // }) :
  //       image = url.endsWith("svg") ? SvgPicture.asset(assetName)

  @override
  Widget build(BuildContext context) {
    return image;
  }
}