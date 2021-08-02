import 'post.dart';

class CachedPost {
  final String id;
  final String title;
  final String body;
  final DateTime publishDate;
  final DateTime insertDate;
  final String authorId;

  const CachedPost(
      {this.id,
      this.title,
      this.body,
      this.publishDate,
      this.authorId,
      this.insertDate});

  CachedPost.fromPost(
    Post post, {
    this.insertDate,
  })  : id = post.id,
        title = post.title,
        body = post.body,
        publishDate = post.publishDate,
        authorId = post.author.id;
}
