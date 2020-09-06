import 'package:equatable/equatable.dart';

class Author extends Equatable {
  final String id;
  final String alias;
  final String avatarUrl;

  const Author({this.id, this.alias, this.avatarUrl});

  @override
  List<Object> get props => [id];
}

class Statistics {
  final int commentsCount;
  final int favoritesCount;
  final int readingCount;
  final int score;
  final int votesCount;

  const Statistics({
    this.commentsCount,
    this.favoritesCount,
    this.readingCount,
    this.score,
    this.votesCount});

  Statistics.fromJson(Map<String, dynamic> json) :
    commentsCount = json['commentsCount'],
    favoritesCount = json['favoritesCount'],
    readingCount = json['readingCount'],
    score = json['score'],
    votesCount = json['votesCount'];
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
  final Statistics statistics;

  const PostPreview({this.id, this.title, this.tags, this.publishDate, this.author, this.statistics});

  @override
  List<Object> get props => [id];
}

class PostPreviews {
  final int maxCountPages;
  final List<PostPreview> previews;

  const PostPreviews({this.previews, this.maxCountPages});
}