import 'author.dart';
import 'statistics.dart';

class PostPreview {
  final String id;
  final String title;
  final List<String>? hubs;
  final List<String> flows;
  final String? htmlPreview;
  final DateTime publishDate;
  final Author author;
  final Statistics statistics;
  final bool corporative;

  const PostPreview({
    required this.id,
    required this.title,
    this.hubs,
    required this.flows,
    this.htmlPreview,
    required this.publishDate,
    required this.author,
    required this.statistics,
    this.corporative = false,
  });
}

class PostPreviews {
  final int maxCountPages;
  final List<PostPreview> previews;

  const PostPreviews({
    required this.previews,
    required this.maxCountPages,
  });
}
