import 'package:habr_app/habr/storage_interface.dart';
import 'package:either_dart/either.dart';
import 'package:habr_app/utils/log.dart';
import 'package:habr_app/utils/http_request_helper.dart';
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

  Future<Either<StorageError, PostPreviews>> posts({int page = 1,}) async {
    final url = "$api_url/articles/?date=day&sort=date&fl=ru&hl=ru&page=$page";
    logInfo("Get articles by $url");
    final response = await safe(http.get(url));
    return response
      .then(checkHttpStatus)
      .map(parseJson)
      .map((data) {
        return PostPreviews(
            previews: data['articleIds'].map<PostPreview>((id) {
              final article = data['articleRefs'][id];
              final authorJson = article['author'];
              return PostPreview(
                  id: id,
                  title: article['titleHtml'],
                  tags: article['flows'].map<String>((
                      flow) => flow['title'] as String).toList(),
                  publishDate: DateTime.parse(article['timePublished']),
                  author: Author.fromJson(authorJson),
                  statistics: Statistics.fromJson(article['statistics'])
              );
            }).toList(),
            maxCountPages: data['pagesCount']
        );
      }
    );
  }

  Future<Either<StorageError, Post>> article(String id) async {
    final url = "$api_url/articles/$id";
    logInfo("Get article by $url");
    final response = await safe(http.get(url));
    return response
      .then(checkHttpStatus)
      .map(parseJson)
      .map((data) => Post.fromJson(data));
  }

  Future<Either<StorageError, Comments>> comments(String articleId) async {
    final url = "$api_url/articles/$articleId/comments";
    logInfo("Get comments by $url");
    final response = await safe(http.get(url));
    return response
      .then(checkHttpStatus)
      .map(parseJson)
      .map((data) {
        return Comments(
          threads: (data['threads'] as List).cast<int>(),
          comments: (data['comments'] as Map<String, dynamic>).map<int,
              Comment>((key, value) {
            return MapEntry(int.parse(key), Comment.fromJson(value));
          }),
        );
    });
  }
}