import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dto.dart';


class Habr {
  static const api_url = "https://m.habr.com/kek/v2";
  Future<List<PostPreview>> posts() async {
    final response = await http.get("$api_url/articles/?date=day&sort=date&fl=ru&hl=ru&page=1");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['articleIds'].map<PostPreview>((id) {
        final article = data['articleRefs'][id];
        return new PostPreview(
          id: id,
          title: article['titleHtml']
        );
      }).toList();
    } else {
      return null;
    }
  }

  Future<Post> article(String id) async {
    final response = await http.get("$api_url/article/$id");
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