import 'dart:convert';
import 'file:///C:/projects/android/habr_app/lib/utils/log.dart';
import 'package:http/http.dart' as http;
import 'dto.dart';


class Habr {
  static const api_url = "https://m.habr.com/kek/v2";
  Future<PostPreviews> posts() async {
    final url = "$api_url/articles/?date=day&sort=date&fl=ru&hl=ru&page=1";
    logInfo("Get articles by $url");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PostPreviews(
        previews: data['articleIds'].map<PostPreview>((id) {
          final article = data['articleRefs'][id];
          final author = article['author'];
          return PostPreview(
            id: id,
            title: article['titleHtml'],
            tags: article['flows'].map<String>((flow) => flow['title'] as String).toList(),
            publishDate: DateTime.parse(article['timePublished']),
            author: Author(
              id: author['id'],
              alias: author['alias'],
              avatarUrl: author['avatarUrl'].toString().replaceFirst("//", "https://")
            ),
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
}