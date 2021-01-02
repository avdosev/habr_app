import 'author.dart';

class Post {
  final String id;
  final String title;
  final String body;
  final DateTime publishDate;
  final Author author;

  const Post({this.id, this.title, this.body, this.publishDate, this.author});
}