import 'author.dart';
import 'package:habr_app/utils/html_to_json/element_builders.dart';

abstract class PostInfo {
  String get id;
  String get title;
  DateTime get publishDate;
  Author get author;
}

class Post implements PostInfo {
  final String id;
  final String title;
  final String body;
  final DateTime publishDate;
  final Author author;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.publishDate,
    required this.author,
  });
}

class ParsedPost implements PostInfo {
  final String id;
  final String title;
  final Node parsedBody;
  final DateTime publishDate;
  final Author author;

  const ParsedPost({
    required this.id,
    required this.title,
    required this.parsedBody,
    required this.publishDate,
    required this.author,
  });
}
