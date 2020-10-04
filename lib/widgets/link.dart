import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../utils/url_open.dart';

class Link extends StatelessWidget {
  final Widget child;
  final String url;
  const Link({this.child, @required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(url),
      child: child,
    );
  }
}



TextSpan InlineTextLink({@required String title, @required String url, @required BuildContext context}) {
  final theme = Theme.of(context);
  return TextSpan(
      text: title,
      style: TextStyle(decoration: TextDecoration.underline, color: theme.primaryColor),
      recognizer: TapGestureRecognizer()
        ..onTap = () => launchUrl(url),
  );
}

class TextLink extends StatelessWidget {
  final String title;
  final String url;
  const TextLink({@required this.title, @required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Link(child: Text(title, style: TextStyle(decoration: TextDecoration.underline, color: theme.primaryColor)), url: url);
  }
}