import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:html/dom.dart' as dom;
import 'package:html/dom_parsing.dart' as dom_parser;
import 'package:html/parser.dart';

import '../log.dart';

class WrappedContainer extends StatelessWidget {
  final List<Widget> children;

  WrappedContainer({this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: children,
      runSpacing: 20,
    );
  }
}

class HtmlView extends StatelessWidget {
  final String html;

  HtmlView(this.html);

  @override
  Widget build(BuildContext context) {
    return WrappedContainer(
        children: parseHtml(html)
    );
  }
}

class Blockquote extends StatelessWidget {
  final List<Widget> children;
  Blockquote({this.children});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: themeData.primaryColor,
            width: 5,
          )
        )
      ),
      padding: const EdgeInsets.all(10),
      child: WrappedContainer(
        children: children
      ),
    );
  }
}

class Spoiler extends StatelessWidget {
  final String title;
  final List<Widget> children;

  Spoiler({this.title, this.children});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return WrappedContainer(
      children: [
        Text(title,
          style: TextStyle(
            color: themeData.primaryColor,
            decorationColor: themeData.primaryColor,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dashed,
          ),
        ),
        ...children // TODO: stealthy children
      ],
    );
  }
}

List<Widget> buildTree(dom.Element element) {
  final widgets = <Widget>[];
  int index = 0;
  for (var node in element.nodes) {
    if (node.nodeType == dom.Node.TEXT_NODE) {
      logInfo('text node');
      widgets.add(Text(node.text));
    } else if (node.nodeType == dom.Node.ELEMENT_NODE) {
      final child = element.children[index++];
      logInfo(child.localName);
      switch (child.localName) {
        case 'h1':
        case 'h2':
        case 'h3':
        case 'h4':
        case 'h5':
        case 'h6':
          widgets.add(Text(child.text, textScaleFactor: 1.2, style: TextStyle(fontWeight: FontWeight.bold),));
          break;
        case 'p': // TODO: support bold and italic
        case 'code': // TODO: special element for code elements
          widgets.add(Text(child.text));
          break;
        case 'img':
          widgets.add(Image.network(child.attributes['data-src'] ?? child.attributes['src']));
          break;
        case 'blockquote':
          widgets.add(Blockquote(children: buildTree(child),));
          break;
        case 'div':
          if (child.classes.contains('spoiler')) {
            widgets.add(
                Spoiler(
                  title: child.getElementsByClassName('spoiler_title')[0].text,
                  children: buildTree(child),
                )
            );
          } else {
            widgets.addAll(buildTree(child));
          }
          break;
        case 'figure':
        case 'pre': // hmm, maybe it has other type
          widgets.addAll(buildTree(child));
          break;
        default:
          logInfo("Not found case for ${child.localName}");
      }
    }
  }
  return widgets;
}

List<Widget> parseHtml(String html) {
  final doc = parse(html);
  final body = doc.getElementsByTagName('body')[0];
  return buildTree(body);
}