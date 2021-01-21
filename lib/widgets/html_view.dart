import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habr_app/stores/app_settings.dart';


import 'html_elements/html_elements.dart';
import 'dividing_block.dart';
import 'link.dart';
import 'picture.dart';

import 'package:habr_app/utils/html_to_json.dart';
import 'package:habr_app/utils/log.dart';

class HtmlView extends StatelessWidget {
  final String html;
  final TextAlign textAlign;

  HtmlView(this.html, {this.textAlign});

  @override
  Widget build(BuildContext context) {
    return parseHtml(html, context);
  }

  Widget parseHtml(String html, BuildContext context) {
    final doc = htmlAsParsedJson(html);
    return buildTree(doc, context);
  }

  Widget buildTree(Map<String, dynamic> element, BuildContext context) {
    final type = element['type'];
    if (type == 'hl') {
      logInfo('$type ${element['text']}');
    } else {
      logInfo(type);
    }
    Widget widget;
    if (type == 'hl') {
      final mode =
      HeadLineType.values[int.parse(element['mode'].substring(1)) - 1];
      widget = HeadLine(text: element['text'], type: mode);
    } else if (type == 'tp') {
      widget = Text(
        element['text'],
        textAlign: textAlign,
      );
    } else if (type == 'paragraph') {
      logInfo(element);
      widget = Text.rich(
        TextSpan(
            children: (element['children'] as List)
                .map<InlineSpan>((child) => buildInline(child, context))
                .toList()),
        textAlign: textAlign,
      );
    } else if (type == 'pre') {
      widget = SingleChildScrollView(
        child: buildTree(element['child'], context),
        scrollDirection: Axis.horizontal,
      );
    } else if (type == 'image') {
      widget = Picture.network(
        element['src'],
        clickable: true,
      );
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
      final appSettings = AppSettings();
      widget = HighlightCode(
        element['text'],
        language:
        element['language'].isNotEmpty ? element['language'].first : "",
        padding: const EdgeInsets.all(10),
        themeMode: appSettings.codeThemeMode,
        themeNameDark: appSettings.darkCodeTheme,
        themeNameLight: appSettings.lightCodeTheme,
      );
    } else if (type == 'blockquote') {
      widget = BlockQuote(
          child: WrappedContainer(
              children: (element['children'] as List)
                  .map<Widget>((child) => buildTree(child, context))
                  .toList()));
    } else if (type == 'ordered_list' || type == 'unordered_list') {
      // TODO: ordered list
      widget = UnorderedList(
          children: element['children']
              .map<Widget>((li) => buildTree(li, context))
              .toList());
    } else if (type == 'div') {
      widget = WrappedContainer(
          children: (element['children'] as List)
              .map<Widget>((child) => buildTree(child, context))
              .toList());
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
      span = InlineTextLink(
          title: element['text'], url: element['src'], context: context);
    } else if (type == 'image_span') {
      span = WidgetSpan(
          child: Picture.network(
            element['src'],
            clickable: true,
          ));
    }

    return span;
  }
}
