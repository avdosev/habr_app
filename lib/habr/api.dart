import 'dart:convert';
import 'package:habr_app/utils/log.dart';
import 'package:http/http.dart' as http;
import 'dto.dart';

enum ArticleFeeds {
  dayTop,
  weekTop,
  yearTop,
  time,
  news
}

enum Flows {
  my,
  all,
  develop,
  admin,
  design,
  management,
  marketing,
  popular_science
}

class Habr {
  static const api_url = "https://m.habr.com/kek/v2";
  Future<PostPreviews> posts({int page = 1,}) async {
    final url = "$api_url/articles/?date=day&sort=date&fl=ru&hl=ru&page=$page";
    logInfo("Get articles by $url");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PostPreviews(
        previews: data['articleIds'].map<PostPreview>((id) {
          final article = data['articleRefs'][id];
          final authorJson = article['author'];
          return PostPreview(
            id: id,
            title: article['titleHtml'],
            tags: article['flows'].map<String>((flow) => flow['title'] as String).toList(),
            publishDate: DateTime.parse(article['timePublished']),
            author: Author.fromJson(authorJson),
            statistics: Statistics.fromJson(article['statistics'])
          );
        }).toList(),
        maxCountPages: data['pagesCount']
      );
    } else {
      return null;
    }
  }

  Future<Post> article(String id) async {
    final url = "$api_url/articles/$id";
    logInfo("Get article by $url");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Post(
        id: data['id'],
        title: data['titleHtml'],
        body: data['textHtml']
      );
    } else {
      return null;
    }
  }

  Future<Comments> comments(String articleId) async {
    final url = "$api_url/articles/$articleId/comments";
    logInfo("Get comments by $url");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Comments(
        threads: data['threads'] as List<int>,
        comments: (data['comments'] as Map<String, dynamic>).map<int, Comment>((key, value) => MapEntry(int.parse(key), Comment.fromJson(value))),
      );
    } else {
      return null;
    }
  }
}