import 'author.dart';

class Comment {
  final int id;
  final int? parentId;
  final int? level;
  final bool banned;
  final DateTime? timePublished;
  final DateTime? timeChanged;
  final List<int>? children;
  final Author? author;
  final String? message;

  bool get notBanned => !banned;

  Comment({
    required this.id,
    this.parentId,
    this.level,
    this.timePublished,
    this.timeChanged,
    this.children,
    this.author,
    this.message,
    required this.banned,
  });

  Comment copyWith({
    int? id,
    int? parentId,
    int? level,
    bool? banned,
    DateTime? timePublished,
    DateTime? timeChanged,
    List<int>? children,
    Author? author,
    String? message,
  }) {
    return Comment(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      timePublished: timePublished ?? this.timePublished,
      timeChanged: timeChanged ?? this.timeChanged,
      children: children ?? this.children,
      author: author ?? this.author,
      message: message ?? this.message,
      banned: banned ?? this.banned,
    );
  }
}

class Comments {
  final Map<int, Comment> comments;
  final List<int> threads;

  Comments({
    required this.comments,
    required this.threads,
  });
}
