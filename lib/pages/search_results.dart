import 'package:flutter/material.dart';
import 'package:habr_app/utils/page_loaders/preview_loader.dart';
import 'package:habr_app/stores/article_store.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'articles_list.dart' as ArticleList;

class SearchResultListPage extends StatefulWidget {
  final SearchLoader loader;
  SearchResultListPage({Key key, @required this.loader}) : super(key: key);

  @override
  createState() => _SearchResultListPageState(loader);
}

class _SearchResultListPageState extends State<SearchResultListPage> {
  ArticlesStorage store;

  _SearchResultListPageState(SearchLoader loader) :
      store = ArticlesStorage(loader);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context).search} ${widget.loader.query}"),
      ),
      body: ArticleList.bodyWidget(store),
    );
  }
}
