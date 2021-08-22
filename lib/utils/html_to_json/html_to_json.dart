import 'dart:convert';
import 'package:html/parser.dart';
import 'transformer.dart';
import 'element_builders.dart';

Node htmlAsParsedJson(String? input) {
  final doc = parse(input);
  final block = prepareHtmlBlocElement(doc.body!.children.first);
  optimizeBlock(block);
  return block;
}
