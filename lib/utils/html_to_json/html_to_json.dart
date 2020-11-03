import 'dart:convert';
import 'package:html/parser.dart';
import 'transformer.dart';

Map<String, dynamic> htmlAsParsedJson(String input) {
  final doc = parse(input);
  final block = prepareHtmlBlocElement(doc.body.children.first);
  optimizeBlock(block);
  return block;
}

String htmlAsJson(String source) {
  return jsonEncode(htmlAsParsedJson(source));
}
