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

  const Post({this.id, this.title, this.body, this.publishDate, this.author});
}

class ParsedPost implements PostInfo {
  final String id;
  final String title;
  final Node parsedBody;
  final DateTime publishDate;
  final Author author;

  const ParsedPost({
    this.id,
    this.title,
    this.parsedBody,
    this.publishDate,
    this.author,
  });
}
