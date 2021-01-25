import 'element_builders.dart';
import 'package:html/dom.dart' as dom;

const blockElements = {
  'body',
  'div',
  'details',
  'figure',
  'pre',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'figcaption',
  'p',
  'img',
  'blockquote',
  'ol',
  'ul',
};

const inlineElements = {
  'strong',
  'code',
  'em',
  'i',
  's',
  'b',
  'a',
  'um',
  'sup'
};

const nameToType = <String, TextMode>{
  'strong': TextMode.strong,
  'em': TextMode.emphasis,
  'i': TextMode.italic,
  's': TextMode.strikethrough,
  'b': TextMode.bold
};

Map<String, dynamic> optimizeParagraph(Map<String, dynamic> p) {
  if (p['children'].length == 1) {
    final span = p['children'][0];
    if (span['type'] == 'span' && span['mode'].isEmpty) {
      return buildTextParagraph(span['text']);
    }
  }
  return p;
}

void optimizeBlock(Map<String, dynamic> block) {
  String blockType = block['type'];
  if (blockType == 'div' ||
      blockType == 'unordered_list' ||
      blockType == 'ordered_list') {
    final children = block['children'] as List;
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final childType = child['type'] as String;
      if (childType == 'div') {
        if (child['children'].length == 1) {
          children[i] = child['children'][0];
        }
      }
      optimizeBlock(child);
    }
  } else if (blockType == 'details') {
    final child = block['child'];
    final childType = child['type'] as String;
    if (childType == 'div' && child['children'].length == 1) {
      block['child'] = child['children'][0];
    } else {
      optimizeBlock(child);
    }
  } else if (blockType == 'tp') {
    block['text'] = (block['text'] as String).trim();
  } else if (blockType == 'paragraph' && block['children'].isNotEmpty) {
    if ((block['children'][0] as Map).containsKey('text')) {
      block['children'][0]['text'] = block['children'][0]['text'].trimLeft();
    }
  }
}

String prepareTextNode(String text) {
  final pattern = RegExp(r'\s+');
  return text.replaceAll(pattern, ' ');
}

List<Map<String, dynamic>> prepareHtmlInlineElement(dom.Element element) {
  final children = <Map<String, dynamic>>[];

  void walk(dom.Element elem, List<TextMode> modes) {
    for (final node in elem.nodes) {
      if (node.nodeType == dom.Node.TEXT_NODE) {
        final text = prepareTextNode(node.text);
        if (text.isNotEmpty) {
          children.add(buildTextSpan(text, modes: List.of(modes)));
        }
      } else if (node.nodeType == dom.Node.ELEMENT_NODE) {
        final child = node as dom.Element;
        if (nameToType.containsKey(child.localName)) {
          modes.add(nameToType[child.localName]);
          walk(child, modes);
          modes.removeLast();
        } else if (child.localName == 'a') {
          if (child.text.isEmpty && child.children.length > 0) {
            walk(child, modes);
          } else {
            children.add(buildInlineLink(child.text, child.attributes['href']));
          }
        } else if (child.localName == 'img') {
          final el = prepareHtmlBlocElement(child);
          el['type'] += '_span';
          children.add(el);
        } else {
          walk(child, modes);
        }
      }
    }
  }

  final defaultStyles = <TextMode>[];
  if (nameToType.containsKey(element.localName)) {
    defaultStyles.add(nameToType[element.localName]);
  } else if (element.localName == 'a' && element.text.isNotEmpty) {
    return [buildInlineLink(element.text, element.attributes['href'])];
  }

  walk(element, defaultStyles);

  return children;
}

List<Map<String, dynamic>> prepareChildrenHtmlBlocElement(dom.Element element) {
  final children = <Map<String, dynamic>>[];
  var paragraph = buildDefaultParagraph();

  void makeNewParagraphAndInsertOlder() {
    if (paragraph['children'].isNotEmpty) {
      children.add(optimizeParagraph(paragraph));
      paragraph = buildDefaultParagraph();
    }
  }

  for (var node in element.nodes) {
    if (node.nodeType == dom.Node.TEXT_NODE) {
      final text = prepareTextNode(node.text);
      if (text.isNotEmpty && text.trim().isNotEmpty) {
        print('text node');
        final pch = (paragraph['children'] as List);
        // may be this branch is not popular or not active
        if (pch.isNotEmpty &&
            pch.last['type'] == 'text_span' &&
            (pch.last['mode'] as List).isEmpty) {
          pch.last.update('text', (value) => (value as String) + text);
        } else {
          pch.add(buildTextSpan(text));
        }
      }
    } else if (node.nodeType == dom.Node.ELEMENT_NODE) {
      // ignore: unnecessary_cast
      final child = node as dom.Element;
      print(child.localName);
      if (blockElements.contains(child.localName)) {
        makeNewParagraphAndInsertOlder();
        final block = prepareHtmlBlocElement(child);
        // block optimization
        if (block['type'] == 'paragraph') {
          if (block['children'].isEmpty) continue;
          if (block['children'].length == 1) {
            final child = block['children'][0];
            if (child['type'] == 'span' && child['text'].trim().isEmpty) continue;
          }
        }
        children.add(block);
      } else if (inlineElements.contains(child.localName)) {
        if (child.localName == 'a' && !child.attributes.containsKey('href')) {
          continue;
        }
        final spans = prepareHtmlInlineElement(node);
        spans.forEach((span) => addSpanToParagraph(paragraph, span));
      } else if (child.localName == 'br') {
        makeNewParagraphAndInsertOlder();
      } else {
        print('Not found case for ${child.localName}');
      }
    }
  }

  makeNewParagraphAndInsertOlder();

  return children;
}

Map<String, dynamic> prepareHtmlBlocElement(dom.Element element) {
  switch (element.localName) {
    case 'h1':
    case 'h2':
    case 'h3':
    case 'h4':
    case 'h5':
    case 'h6':
      return buildHeadLine(element.text.trim(), element.localName);
    case 'figcaption':
      final p = buildDefaultParagraph();
      addSpanToParagraph(p, prepareHtmlInlineElement(element));
      return p;
    case 'p':
      final p = buildDefaultParagraph();
      prepareHtmlInlineElement(element)
          .forEach((span) => addSpanToParagraph(p, span));
      return p;
    case 'code':
      final code = element.text;
      return buildCode(
        code,
        element.classes.toList()..removeWhere((element) => element == 'hljs'),
      );
    case 'img':
      final url = element.attributes['data-src'] ?? element.attributes['src'];
      return buildImage(url);
      break;
    case 'blockquote':
      return buildBlockQuote(prepareChildrenHtmlBlocElement(element));
    case 'ol':
    case 'ul':
      final type =
          element.localName == 'ol' ? ListType.ordered : ListType.unordered;
      return buildList(type,
          element.children.map((li) => prepareHtmlBlocElement(li)).toList());
      break;
    case 'body':
    case 'div':
    case 'li':
      if (element.classes.contains('spoiler')) {
        return buildDetails(
          element.getElementsByClassName('spoiler_title')[0].text,
          prepareHtmlBlocElement(
              element.getElementsByClassName('spoiler_text')[0]),
        );
      } else {
        return buildDiv(prepareChildrenHtmlBlocElement(element));
      }
      break;
    case 'details':
      return buildDetails(
        element.children[0].text,
        prepareHtmlBlocElement(element.children[1]),
      );
    case 'figure':
      final img = element.getElementsByTagName('img')[0];
      final caption = element.getElementsByTagName('figcaption')[0];
      final imgBloc = prepareHtmlBlocElement(img);
      if (caption.text.isNotEmpty) {
        addCaption(imgBloc, caption.text);
      }
      return imgBloc;
    case 'pre':
      if (element.children.isEmpty) return buildPre(buildCode(element.text, []));
      return buildPre(prepareHtmlBlocElement(element.children.first));
    default:
      print('Not found case for ${element.localName}');
      throw UnsupportedError('${element.localName} not supported');
  }
}
