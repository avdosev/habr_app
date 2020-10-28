Map<String, dynamic> buildWithChildren(String type, List<dynamic> children) =>
    {'type': type, 'children': children};

Map<String, dynamic> buildWithChild(String type, dynamic child) =>
    {'type': type, 'child': child};

enum TextMode {
  bold,
  italic,
  emphasis,
  underline,
  strikethrough,
  anchor,
  strong
}

enum ListType { unordered, ordered }

Map<String, dynamic> buildDefaultParagraph() =>
    {'type': 'paragraph', 'children': []};

void addSpanToParagraph(p, span) {
  final pch = (p['children'] as List);
  pch.add(span);
}

bool paragraphIsEmpty(p) {
  return p['children'].isEmpty;
}

Map<String, dynamic> buildTextParagraph(String text) => {
  'type': 'tp',
  'text': text,
};

Map<String, dynamic> buildTextSpan(String text,
    {List<TextMode> modes = const []}) =>
    {
      'type': 'span',
      'text': text,
      'mode': modes.map((mode) => mode.toString()).toList(),
    };

Map<String, dynamic> buildHeadLine(String text, String headline) => {
  'type': 'hl',
  'text': text,
  'mode': headline,
};

Map<String, dynamic> buildImage(String src) => {
  'type': 'image',
  'src': src,
};

Map<String, dynamic> buildCode(String text, List<String> language) =>
    {'type': 'code', 'text': text, 'language': language};

void addCaption(image, String caption) {
  image['caption'] = caption;
}

Map<String, dynamic> buildList(ListType listType, List<dynamic> children) =>
    buildWithChildren(
        listType.toString().substring('ListType'.length + 1) + '_list',
        children);

Map<String, dynamic> buildDetails(String title, child) =>
    {'type': 'details', 'child': child, 'title': title};

Map<String, dynamic> buildPre(dynamic child) => buildWithChild('pre', child);

Map<String, dynamic> buildDiv(List<dynamic> children) =>
    buildWithChildren('division', children);

Map<String, dynamic> buildBlockQuote(List<dynamic> children) =>
    buildWithChildren('blockquote', children);

Map<String, dynamic> buildInlineLink(String text, String src) =>
    {'type': 'link_span', 'text': text, 'src': src};