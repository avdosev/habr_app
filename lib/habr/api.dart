import 'package:either_dart/either.dart';
import 'package:habr_app/app_error.dart';
import 'package:habr_app/models/models.dart';
import 'package:habr_app/utils/log.dart';
import 'package:habr_app/utils/http_request_helper.dart';
import 'package:http/http.dart' as http;
import 'json_parsing.dart';

enum ArticleFeeds { dayTop, weekTop, yearTop, time, news }

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

enum Order { Date, Relevance, Rating }

const orderToText = {
  Order.Date: 'date',
  Order.Rating: 'rating',
  Order.Relevance: 'relevance'
};

class Habr {
  static const api_url_v2 = "https://m.habr.com/kek/v2";

  Future<Either<AppError, PostPreviews>> findPosts(String query,
      {int page = 1, Order order = Order.Relevance}) async {
    String ordString = orderToText[order];
    final url =
        "$api_url_v2/articles/?query=$query&order=$ordString&fl=ru&hl=ru&page=$page";
    final response = await safe(http.get(url));
    return response
        .then(checkHttpStatus)
        .map(parseJson)
        .map((data) => parsePostPreviewsFromJson(data));
  }

  Future<Either<AppError, PostPreviews>> posts({
    int page = 1,
  }) async {
    final url =
        "$api_url_v2/articles/?period=daily&sort=date&fl=ru&hl=ru&page=$page";
    logInfo("Get articles by $url");
    final response = await safe(http.get(url));
    return response
        .then(checkHttpStatus)
        .asyncMap(asyncParseJson)
        .then((val) => val.map((data) => parsePostPreviewsFromJson(data)));
  }

  Future<Either<AppError, PostPreviews>> userPosts(String user,
      {int page = 1}) async {
    final url =
        "$api_url_v2/articles/?user=$user&sort=date&fl=ru&hl=ru&page=$page";
    logInfo("Get articles by $url");
    final response = await safe(http.get(url));
    return response
        .then(checkHttpStatus)
        .asyncMap(asyncParseJson)
        .then((val) => val.map((data) => parsePostPreviewsFromJson(data)));
  }

  Future<Either<AppError, Post>> article(String id) async {
    final url = "$api_url_v2/articles/$id";
    logInfo("Get article by $url");
    final response = await safe(http.get(url));
    return response
        .then(checkHttpStatus)
        .asyncMap(asyncParseJson)
        .then((val) => val.map((data) => parsePostFromJson(data)));
  }

  Future<Either<AppError, Comments>> comments(String articleId) async {
    final url = "$api_url_v2/articles/$articleId/comments";
    logInfo("Get comments by $url");
    final response = await safe(http.get(url));
    return response
        .then(checkHttpStatus)
        .map(parseJson)
        .map((data) => parseCommentsFromJson(data));
  }
}
