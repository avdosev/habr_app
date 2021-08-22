import 'package:flutter/material.dart';
import 'package:habr_app/utils/page_loaders/preview_loader.dart';
import 'package:habr_app/pages/pages.dart';

void openArticle(BuildContext context, String articleId) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ArticlePage(articleId: articleId)));
}

void openCommentsPage(BuildContext context, String articleId) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CommentsPage(
            articleId: articleId,
          )));
}

void openSearch(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => SearchPage()));
}

void openSearchResult(BuildContext context, SearchData info) {
  final loader = SearchLoader(info);
  Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SearchResultListPage(loader: loader)));
}

void openFilters(BuildContext context) {
  Navigator.pushNamed(context, "filters");
}

void openUser(BuildContext context, String username) {
  Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => UserPage(username: username)));
}

Map<String, WidgetBuilder> routes = {
  "settings": (BuildContext context) => SettingsPage(),
  "articles": (BuildContext context) => ArticlesList(),
  "articles/cached": (BuildContext context) => CachedArticlesList(),
  "articles/bookmarks": (BuildContext context) => BookmarksArticlesList(),
  "filters": (BuildContext context) => FiltersPage(),
};
