import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/androidstudio.dart';

import 'html_elements/html_elements.dart';
import 'dividing_block.dart';
import 'link.dart';
import 'picture.dart';

import 'package:habr_app/utils/html_to_json.dart';
import 'package:habr_app/utils/log.dart';

class HtmlView extends StatelessWidget {
  final String html;

  HtmlView(this.html);

  @override
  Widget build(BuildContext context) {
    return parseHtml(html, context);
  }
}

InlineSpan buildInline(Map<String, dynamic> element, BuildContext context) {
  InlineSpan span;
  String type = element['type'];
  if (element['type'] == 'span') {
    var style = TextStyle();
    for (final mode in (element['mode'] as List<String>)) {
      if (mode == 'bold' || mode == 'strong') {
        style = style.copyWith(fontWeight: FontWeight.w500);
      } else if (mode == 'italic' || mode == 'emphasis') {
        style = style.copyWith(fontStyle: FontStyle.italic);
      } else if (mode == 'underline') {
        style = style.copyWith(decoration: TextDecoration.underline);
      } else if (mode == 'strikethrough') {
        style = style.copyWith(decoration: TextDecoration.lineThrough);
      }
    }
    span = TextSpan(text: element['text'], style: style);
  } else if (type == 'link_span') {
    span = InlineTextLink(title: element['text'], url: element['src'], context: context);
  } else if (type == 'image_span') {
    span = WidgetSpan(child: Picture.network(element['src'], clickable: true,));
  }

  return span;
}

Widget buildTree(Map<String, dynamic> element, BuildContext context) {
  final type = element['type'];
  logInfo(type);
  Widget widget;
  if (type == 'hl') {
    final mode = HeadLineType.values[int.parse(element['mode'].substring(1)) - 1];
    widget =
      HeadLine(
        text: element['text'],
        type: mode
    );
  } else if (type == 'tp') {
    widget = Text(element['text']);
  } else if (type == 'paragraph') {
    logInfo(element);
    widget =
       Text.rich(
         TextSpan(
           children: (element['children'] as List)
               .map<InlineSpan>((child) => buildInline(child, context))
               .toList()
         )
   );
  } else if (type == 'pre') {
    widget = SingleChildScrollView(
      child: buildTree(element['child'], context),
      scrollDirection: Axis.horizontal,
    );
  } else if (type == 'image') {
    widget = Picture.network(element['src'], clickable: true,);
    if (element.containsKey('caption')) {
      widget = WrappedContainer(
        children: [
          widget,
          Text(element['caption'], style: Theme.of(context).textTheme.subtitle2)
        ],
        distance: 5,
      );
    }
  } else if (type == 'code') {
    widget = HighlightView(
      // The original code to be highlighted
        element['text'],
        // Specify language
        // It is recommended to give it a value for performance
        language: element['language'].isNotEmpty ? element['language'].first : "",
        padding: const EdgeInsets.all(10),

        // Specify highlight theme
        // All available themes are listed in `themes` folder
        theme: androidstudioTheme,

        // Specify text style
        textStyle: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        )
    );
  } else if (type == 'blockquote') {
    widget = BlockQuote(
        child: WrappedContainer(
          children: (element['children'] as List)
              .map<Widget>((child) => buildTree(child, context))
              .toList()
        )
    );
  } else if (type == 'ordered_list' || type == 'unordered_list') {
    // TODO: ordered list
    widget = UnorderedList(
        children: element['children']
            .map<Widget>((li) => buildTree(li, context))
            .toList()
    );
  } else if (type == 'div') {
    widget = WrappedContainer(
        children: (element['children'] as List)
            .map<Widget>((child) => buildTree(child, context))
            .toList()
    );
  } else if (type == 'details') {
    widget = Spoiler(
      title: element['title'],
      child: buildTree(element['child'], context),
    );
  } else {
    logInfo("Not found case for $type");
  }
  return widget;
}

Widget parseHtml(String html, BuildContext context) {
  final doc = htmlAsParsedJson(html);
  return buildTree(doc, context);
}