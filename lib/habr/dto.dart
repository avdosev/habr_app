import 'package:equatable/equatable.dart';

class Author extends Equatable {
  final String id;
  final String alias;
  final String avatarUrl;

  const Author({this.id, this.alias, this.avatarUrl});

  @override
  List<Object> get props => [id];

}

class Post extends Equatable {
  final String id;
  final String title;
  final String body;

  const Post({this.id, this.title, this.body});

  @override
  List<Object> get props => [id];
}

class PostPreview extends Equatable {
  final String id;
  final String title;
  final List<String> tags;
  final DateTime publishDate;
  final Author author;

  const PostPreview({this.id, this.title, this.tags, this.publishDate, this.author});

  @override
  List<Object> get props => [id];
}

class PostPreviews {
  final int maxCountPages;
  final List<PostPreview> previews;

  const PostPreviews({this.previews, this.maxCountPages});
}