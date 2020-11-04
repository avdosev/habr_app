import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'image_info.dart';

ImageInfo prepareAvatarUrl(String url) {
  if (url == null) return ImageInfo(url: null, store: ImageStoreType.Default);
  if (url.startsWith("//")) url = url.replaceFirst("//", "https://");
  return ImageInfo(url: url, store: ImageStoreType.Network);
}

class Author extends Equatable {
  final String id;
  final String alias;
  final ImageInfo avatar;

  const Author({this.id, this.alias, this.avatar});

  @override
  List<Object> get props => [id];

  Author.fromJson(Map<String, dynamic> json) :
      id = json['id'],
      alias = json['alias'],
      avatar = prepareAvatarUrl(json['avatarUrl']);
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

  Statistics.zero() :
      commentsCount = 0,
      favoritesCount = 0,
      readingCount = 0,
      score = 0,
      votesCount = 0
  ;
}

class Post extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime publishDate;
  final Author author;

  const Post({this.id, this.title, this.body, this.publishDate, this.author});

  Post.fromJson(Map<String, dynamic> data):
      id = data['id'],
      title = data['titleHtml'],
      body = data['textHtml'],
      publishDate = DateTime.parse(data['timePublished']),
      author = Author.fromJson(data['author'])
      ;

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

  PostPreviews.fromJson(Map<String, dynamic> data):
    previews = data['articleIds'].map<PostPreview>((id) {
      final article = data['articleRefs'][id];
      return PostPreview(
        id: id,
        title: article['titleHtml'],
        tags: article['flows'].map<String>(
                (flow) => flow['title'] as String).toList(),
        publishDate: DateTime.parse(article['timePublished']),
        author: Author.fromJson(article['author']),
        statistics: Statistics.fromJson(article['statistics'])
      );
    }).toList(),
    maxCountPages = data['pagesCount'];
}

class Comment {
  final int id;
  final int parentId;
  final int level;
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
  });

  Comment.fromJson(Map<String, dynamic> json):
      id = json['id'],
      parentId = json['parentId'],
      level = json['level'],
      timePublished = DateTime.parse(json['timePublished']),
      timeChanged = json['timeChanged'] == null ? null : DateTime.parse(json['timeChanged']),
      children = (json['children'] as List).cast<int>(),
      author = Author.fromJson(json['author']),
      message = json['message'];
}

class Comments {
  final Map<int, Comment> comments;
  final List<int> threads;

  Comments({
    this.comments,
    this.threads,
  });
}