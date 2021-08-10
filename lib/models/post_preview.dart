import 'author.dart';
import 'statistics.dart';

class PostPreview {
  final String id;
  final String title;
  final List<String> hubs;
  final List<String> flows;
  final String htmlPreview;
  final DateTime publishDate;
  final Author author;
  final Statistics statistics;
  final bool corporative;

  const PostPreview(
      {this.id,
      this.title,
      this.hubs,
      this.flows,
      this.htmlPreview,
      this.publishDate,
      this.author,
      this.statistics,
      this.corporative = false});
}

class PostPreviews {
  final int maxCountPages;
  final List<PostPreview> previews;

  const PostPreviews({this.previews, this.maxCountPages});
}
