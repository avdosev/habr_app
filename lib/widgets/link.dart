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