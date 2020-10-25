import 'package:flutter/material.dart';
import 'package:habr_app/pages/pages.dart';


openArticle(BuildContext context, String articleId) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ArticlePage(articleId: articleId)));
}