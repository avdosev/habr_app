import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/androidstudio.dart';

import 'package:html/dom.dart' as dom;
import 'package:html/dom_parsing.dart' as dom_parser;
import 'package:html/parser.dart';

import '../utils/log.dart';
import 'dividing_block.dart';
import 'link.dart';
import 'quote_block.dart';
import 'spoiler_block.dart';


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

enum HeadLineType {
  h1, h2, h3, h4, h5, h6
}

class HeadLine extends StatelessWidget {
  final String text;
  final HeadLineType type;
  const HeadLine({this.text, this.type});

  @override
  Widget build(BuildContext context) {
    return Text(text, textScaleFactor: 1.2, style: TextStyle(fontWeight: FontWeight.bold),);
  }

}

List<InlineSpan> buildInline(dom.Element element) {
  final inline = <InlineSpan>[];
  int index = 0;
  for (var node in element.nodes) {
    if (node.nodeType == dom.Node.TEXT_NODE) {
      final text = node.text;
      if (text.length != 0) {
        logInfo('text node "$text"');
        inline.add(TextSpan(text: text));
      }
    } else if (node.nodeType == dom.Node.ELEMENT_NODE) {
      final child = element.children[index++];
      logInfo(child.localName);
      switch(child.localName) {
        case 's':
          inline.add(TextSpan(children: buildInline(child), style: TextStyle(decoration: TextDecoration.lineThrough)));
          break;
        case 'i':
          inline.add(TextSpan(children: buildInline(child), style: TextStyle(fontStyle: FontStyle.italic)));
          break;
        case 'code':
        case 'em':
          inline.add(TextSpan(children: buildInline(child)));
          break;
        case 'b':
        case 'strong':
          inline.add(TextSpan(children: buildInline(child), style: TextStyle(fontWeight: FontWeight.w500),));
          break;
        case 'a':
          inline.add(WidgetSpan(child: TextLink(title: child.text, url: child.attributes['href'])));
          break;
        default:
          logInfo("Not found case for inline ${child.localName}");
      }
    }
  }
  return inline;
}

List<Widget> buildTree(dom.Element element) {
  final widgets = <Widget>[];
  int index = 0;
  for (var node in element.nodes) {
    if (node.nodeType == dom.Node.TEXT_NODE) {
      final text = node.text.trim();
      if (text.length != 0) {
        logInfo('text node "$text"');
        widgets.add(Text(text));
      }
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
          widgets.add(
            HeadLine(
              text: child.text,
              type: HeadLineType.values[int.parse(child.localName.substring(1))-1]
            )
          );
          break;
        case 'p': // TODO: support bold and italic
          if (child.children.length > 0) widgets.add(Text.rich(TextSpan(children: buildInline(child))));
          else widgets.add(Text(child.text));
          break;
        case 'i':
        case 's':
        case 'em':
          widgets.add(Text(child.text));
          break;
        case 'b':
        case 'strong':
          widgets.add(Text(child.text, style: TextStyle(fontWeight: FontWeight.w500),));
          break;
        case 'a':
          if (child.children.length > 0) widgets.add(Link(child: Text.rich(TextSpan(children: buildInline(child))), url: child.attributes['href'],));
          else if (child.text.length != 0) widgets.add(TextLink(title: child.text, url: child.attributes['href']));
          break;
        case 'code': // TODO: special element for code elements
          final code = child.text;
          if (child.classes.length > 0)
            widgets.add(HighlightView(
              // The original code to be highlighted
              code,
              // Specify language
              // It is recommended to give it a value for performance
              language: child.classes.lastWhere((element) => element != 'hljs'),
              padding: const EdgeInsets.all(10),

              // Specify highlight theme
              // All available themes are listed in `themes` folder
              theme: androidstudioTheme,

              // Specify text style
              textStyle: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              )
            ));
          else
            widgets.add(Text(code));
          break;
        case 'img':
          widgets.add(Image.network(child.attributes['data-src'] ?? child.attributes['src']));
          break;
        case 'blockquote':
          widgets.add(BlockQuote(child: WrappedContainer(children: buildTree(child),)));
          break;
        case 'div':
          if (child.classes.contains('spoiler')) {
            widgets.add(
                Spoiler(
                  title: child.getElementsByClassName('spoiler_title')[0].text,
                  child: WrappedContainer(children: buildTree(child)),
                )
            );
          } else {
            widgets.addAll(buildTree(child));
          }
          break;
        case 'details':
          widgets.add(
              Spoiler(
                title: child.children[0].text,
                child: WrappedContainer(children: buildTree(child.children[1])),
              )
          );
          break;
        case 'figure':
        case 'pre': // hmm, maybe it has other type
          widgets.addAll(buildTree(child));
          break;
        case 'br':
          // Nothing
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