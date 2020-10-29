import 'dart:convert';
import 'package:html/parser.dart';
import 'transformer.dart';

Map<String, dynamic> htmlAsParsedJson(String input) {
  final doc = parse(input);
  return prepareHtmlBlocElement(doc.body.children.first);
}

String htmlAsJson(String source) {
  return jsonEncode(htmlAsParsedJson(source));
}


