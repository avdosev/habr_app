import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:html/dom.dart' as dom;
import 'package:html/dom_parsing.dart' as dom_parser;
import 'package:html/parser.dart';

import '../log.dart';

class HtmlView extends StatelessWidget {
  final String html;

  HtmlView(this.html);

  @override
  Widget build(BuildContext context) {
    return Wrap(
        children: parseHtml(html),
        runSpacing: 20,
    );
  }
}

class Blockquote extends StatelessWidget {
  final List<Widget> children;
  Blockquote({this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.blueGrey,
            width: 5,
          )
        )
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: children,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}

List<Widget> parseHtml(String html) {
  final doc = parse(html);
  List<Widget> buildTree(List<dom.Element> children) {
    final widgets = <Widget>[];
    for (var child in children) {
      logInfo(child.localName);
      switch (child.localName) {
        case 'h1':
        case 'h2':
        case 'h3':
        case 'h4':
          widgets.add(Text(child.text, textScaleFactor: 1.2,));
          break;
        case 'p':
        case 'code': // TODO: special element for code elements
          widgets.add(Text(child.text));
          break;
        case 'img':
          widgets.add(Image.network(child.attributes['data-src'] ?? child.attributes['src']));
          break;
        case 'blockquote':
          widgets.add(Blockquote(children: buildTree(child.children),));
          break;
        case 'div':
        case 'figure':
        case 'pre': // hmm, maybe it isn`t Column
          widgets.addAll(buildTree(child.children));
          break;
        default:
          logInfo("Not found case for ${child.localName}");
      }
    }
    return widgets;
  }

  return buildTree(doc.getElementsByTagName('body')[0].children);
}