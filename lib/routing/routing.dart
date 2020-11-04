import 'package:flutter/material.dart';
import 'package:habr_app/pages/pages.dart';


void openArticle(BuildContext context, String articleId) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ArticlePage(articleId: articleId)));
}

void openCommentsPage(BuildContext context, String articleId) {
  Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CommentsPage(articleId: articleId,))
  );
}

void openSearch(BuildContext context) {
  Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SearchPage())
  );
}