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

enum Order {
  Date,
  Relevance,
  Rating
}

const orderToText = {
  Order.Date: 'date',
  Order.Rating: 'rating',
  Order.Relevance: 'relevance'
};

class Habr {
  static const api_url_v2 = "https://m.habr.com/kek/v2";

  Future<Either<StorageError, PostPreviews>> findPosts(String query, {int page = 1, Order order = Order.Relevance}) async {
    String ordString = orderToText[order];
    final url = "$api_url_v2/articles/?query=$query&order=$ordString&fl=ru&hl=ru&page=$page";
    final response = await safe(http.get(url));
    return response
      .then(checkHttpStatus)
      .map(parseJson)
      .map((data) => PostPreviews.fromJson(data));
  }

  Future<Either<StorageError, PostPreviews>> posts({int page = 1,}) async {
    final url = "$api_url_v2/articles/?period=daily&sort=date&fl=ru&hl=ru&page=$page";
    logInfo("Get articles by $url");
    final response = await safe(http.get(url));
    return response
      .then(checkHttpStatus)
      .map(parseJson)
      .map((data) => PostPreviews.fromJson(data));
  }

  Future<Either<StorageError, Post>> article(String id) async {
    final url = "$api_url_v2/articles/$id";
    logInfo("Get article by $url");
    final response = await safe(http.get(url));
    return response
      .then(checkHttpStatus)
      .map(parseJson)
      .map((data) => Post.fromJson(data));
  }

  Future<Either<StorageError, Comments>> comments(String articleId) async {
    final url = "$api_url_v2/articles/$articleId/comments";
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