import 'dart:ui';

import 'package:habr_app/utils/html_to_json/element_builders.dart';
import 'package:habr_app/utils/html_to_json.dart';

List<String> getImageUrlsFromHtml(String html) {
  final parsedHtml = htmlAsParsedJson(html);
  final urls = getImagesFromParsedPost(parsedHtml).toList();
  return urls;
}

Iterable<String> getImagesFromParsedPost(Node element) sync* {
  if (element is Image) {
    yield element.src;
  } else if (element is NodeChild) {
    yield* getImagesFromParsedPost(element.child);
  } else if (element is NodeChildren) {
    for (final child in element.children)
      yield* getImagesFromParsedPost(child);
  } else if (element is Paragraph) {
    for (final span in element.children) {
      if (span is BlockSpan) {
        yield* getImagesFromParsedPost(span.child);
      }
    }
  }
}