import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:habr_app/utils/url_open.dart';

class Link extends StatelessWidget {
  final Widget? child;
  final String? url;
  const Link({this.child, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(context, url!),
      child: child,
    );
  }
}

TextSpan InlineTextLink(
    {required String title,
    required String? url,
    required BuildContext context}) {
  return TextSpan(
    text: title,
    style: linkTextStyleFrom(context),
    recognizer: TapGestureRecognizer()..onTap = () => launchUrl(context, url!),
  );
}

class TextLink extends StatelessWidget {
  final String title;
  final String? url;
  const TextLink({required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return Link(
      child: Text(
        title,
        style: linkTextStyleFrom(context),
      ),
      url: url,
    );
  }
}

Color linkColorFrom(BuildContext context) {
  return Theme.of(context).toggleableActiveColor;
}

TextStyle linkTextStyleFrom(BuildContext context) {
  final color = linkColorFrom(context);
  return TextStyle(
    decoration: TextDecoration.underline,
    color: color,
  );
}
