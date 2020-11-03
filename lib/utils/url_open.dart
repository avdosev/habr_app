import 'package:flutter/material.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:url_launcher/url_launcher.dart';

launchUrl(BuildContext context, String url) async {
  // TODO: open habr url in app
  if (url.startsWith(RegExp("https?://(m\.)?habr\.com"))) {
    final postRegexp = RegExp(r"https?://(m\.)?habr\.com/((ru|en)/)?post/(\d+)/?");
    final matchPost = postRegexp.firstMatch(url);
    if (matchPost != null) {
      final postId = matchPost.group(4); // post id
      openArticle(context, postId);
    } else {
      print("no match");
    }
    return;
  }
  await launch(url);
}