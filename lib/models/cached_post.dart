import 'post.dart';

class CachedPost {
  final String id;
  final String title;
  final String body;
  final DateTime publishDate;
  final DateTime insertDate;
  final String authorId;

  const CachedPost({
    required this.id,
    required this.title,
    required this.body,
    required this.publishDate,
    required this.authorId,
    required this.insertDate,
  });

  CachedPost.fromPost(
    Post post, {
    required this.insertDate,
  })  : id = post.id,
        title = post.title,
        body = post.body,
        publishDate = post.publishDate,
        authorId = post.author.id;
}
