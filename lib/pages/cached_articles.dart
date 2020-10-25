import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:habr_app/widgets/incrementally_loading_listview.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:habr_app/stores/article_store.dart';
import 'package:habr_app/routing/routing.dart';

class CachedArticlesList extends StatefulWidget {
  CachedArticlesList({Key key}) : super(key: key);

  @override
  createState() => _CachedArticlesListState();
}

class _CachedArticlesListState extends State<CachedArticlesList> {
  final store = ArticlesStorage();

  _CachedArticlesListState() {
    store.loadFirstPage();
  }

  Widget bodyWidget() {
    return Observer(
      builder:(context) {
        Widget widget;
        switch (store.firstLoading) {
          case LoadingState.isFinally:
            widget = SeparatedIncrementallyLoadingListView(
              itemBuilder: (context, index) {
                if (index >= store.previews.length && store.loadItems)
                  return const CircularItem();
                final preview = store.previews[index];
                return ArticlePreview(
                  postPreview: preview,
                  onPressed: (articleId) => openArticle(context, articleId),
                );
              },
              separatorBuilder: (context, index) => const Hr(),
              itemCount: () => store.previews.length + (store.loadItems ? 1 : 0),
              loadMore: store.loadNextPage,
              hasMore: store.hasNextPages,
            );
            break;
          case LoadingState.inProgress:
            widget = Center(child: CircularProgressIndicator());
            break;
          case LoadingState.isCorrupted:
            widget = Center(child: EmptyContent());
            break;
        }
      return widget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Cached articles"),
        ),
        body: bodyWidget()
    );
  }
}