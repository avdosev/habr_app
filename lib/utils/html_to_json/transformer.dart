import 'dart:ui';

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
  'iframe',
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

Node optimizeParagraph(Paragraph p) {
  if (p.children.length == 1) {
    final span = p.children[0];
    if (span is TextSpan && span.modes.isEmpty) {
      return TextParagraph(span.text);
    }
  }
  return p;
}

void optimizeBlock(Node block) {
  if (block is NodeChildren) {
    final children = block.children;
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      if (child is BlockColumn) {
        if (child.children.length == 1) {
          children[i] = child.children[0];
        }
      }
      optimizeBlock(child);
    }
  } else if (block is Details) {
    final child = block.child;
    if (child is BlockColumn && child.children.length == 1) {
      block.child = child.children[0];
    } else {
      optimizeBlock(child);
    }
  } else if (block is TextParagraph) {
    block.text = block.text.trim();
  } else if (block is Paragraph && block.children.isNotEmpty) {
    final childSpan = block.children[0];
    if (childSpan is TextSpan) {
      childSpan.text = childSpan.text.trimLeft();
    }
  }
}

String prepareTextNode(String text) {
  final pattern = RegExp(r'\s+');
  return text.replaceAll(pattern, ' ');
}

List<Span> prepareHtmlInlineElement(dom.Element element) {
  final children = <Span>[];

  void walk(dom.Element elem, List<TextMode> modes) {
    for (final node in elem.nodes) {
      if (node.nodeType == dom.Node.TEXT_NODE) {
        final text = prepareTextNode(node.text);
        if (text.isNotEmpty) {
          children.add(TextSpan(text, modes: List.of(modes)));
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
            children.add(LinkSpan(child.text, child.attributes['href']));
          }
        } else if (child.localName == 'img') {
          final el = prepareHtmlBlocElement(child);
          children.add(BlockSpan(el));
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
    return [LinkSpan(element.text, element.attributes['href'])];
  }

  walk(element, defaultStyles);

  return children;
}

List<Node> prepareChildrenHtmlBlocElement(dom.Element element) {
  final children = <Node>[];
  var paragraph = Paragraph.empty();

  void makeNewParagraphAndInsertOlder() {
    if (paragraph.children.isNotEmpty) {
      children.add(optimizeParagraph(paragraph));
      paragraph = Paragraph.empty();
    }
  }

  for (var node in element.nodes) {
    if (node.nodeType == dom.Node.TEXT_NODE) {
      final text = prepareTextNode(node.text);
      if (text.isNotEmpty && text.trim().isNotEmpty) {
        print('text node');
        final pch = paragraph.children;
        // may be this branch is not popular or not active
        if (pch.isNotEmpty) {
          final latestSpan = pch.last;
          if (latestSpan is TextSpan && latestSpan.modes.isEmpty) {
            latestSpan.text += text;
          } else {
            pch.add(TextSpan(text));
          }
        } else {
          pch.add(TextSpan(text));
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
        if (block is Paragraph) {
          if (block.children.isEmpty) continue;
          if (block.children.length == 1) {
            final child = block.children[0];
            if (child is TextSpan && child.text.trim().isEmpty)
              continue;
          }
        }
        children.add(block);
      } else if (inlineElements.contains(child.localName)) {
        if (child.localName == 'a' && !child.attributes.containsKey('href')) {
          continue;
        }
        final spans = prepareHtmlInlineElement(node);
        spans.forEach(paragraph.addSpan);
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

Node prepareHtmlBlocElement(dom.Element element) {
  switch (element.localName) {
    case 'h1':
    case 'h2':
    case 'h3':
    case 'h4':
    case 'h5':
    case 'h6':
      return HeadLine(element.text.trim(), element.localName);
    case 'figcaption':
    case 'p':
      final p = Paragraph.empty();
      prepareHtmlInlineElement(element).forEach(p.addSpan);
      return p;
    case 'code':
      final code = element.text;
      return Code(
        code,
        findLanguageFromClass(element.classes.toList()),
      );
    case 'img':
      final url = element.attributes['data-src'] ?? element.attributes['src'];
      return Image(url);
      break;
    case 'blockquote':
      return BlockQuote(BlockColumn(prepareChildrenHtmlBlocElement(element)));
    case 'ol':
    case 'ul':
      final type =
          element.localName == 'ol' ? ListType.ordered : ListType.unordered;
      return BlockList(type,
          element.children.map((li) => prepareHtmlBlocElement(li)).toList());
      break;
    case 'body':
    case 'div':
    case 'li':
      if (element.classes.contains('spoiler')) {
        return Details(
          element.getElementsByClassName('spoiler_title')[0].text,
          prepareHtmlBlocElement(
              element.getElementsByClassName('spoiler_text')[0]),
        );
      } else if (element.classes.contains('tm-iframe_temp')) {
        final src = element.attributes['data-src'];
        return Iframe(src);
      } else {
        return BlockColumn(prepareChildrenHtmlBlocElement(element));
      }
      break;
    case 'details':
      return Details(
        element.children[0].text,
        prepareHtmlBlocElement(element.children[1]),
      );
    case 'figure':
      final img = element.getElementsByTagName('img')[0];
      final caption = element.getElementsByTagName('figcaption')[0];
      final url = img.attributes['data-src'] ?? img.attributes['src'];
      final imgBlock = Image(url);
      if (caption.text.isNotEmpty) {
        imgBlock.caption = caption.text;
      }
      return imgBlock;
    case 'pre':
      if (element.children.isEmpty) return Scrollable(Code(element.text, ""));
      return Scrollable(prepareHtmlBlocElement(element.children.first));
    case 'iframe':
      final src = element.attributes['src'];
      return Iframe(src);
    default:
      print('Not found case for ${element.localName}');
      throw UnsupportedError('${element.localName} not supported');
  }
}

String findLanguageFromClass(List<String> classes) {
  classes.removeWhere((element) => element == 'hljs');
  if (classes.isEmpty) return null;
  return classes.first;
}
