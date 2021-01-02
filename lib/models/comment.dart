import 'author.dart';

class Comment {
  final int id;
  final int parentId;
  final int level;
  final bool banned;
  final DateTime timePublished;
  final DateTime timeChanged;
  final List<int> children;
  final Author author;
  final String message;

  Comment({
    this.id,
    this.parentId,
    this.level,
    this.timePublished,
    this.timeChanged,
    this.children,
    this.author,
    this.message,
    this.banned
  });
}

class Comments {
  final Map<int, Comment> comments;
  final List<int> threads;

  Comments({
    this.comments,
    this.threads,
  });
}