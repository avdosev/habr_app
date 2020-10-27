import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:habr_app/stores/article_store.dart';
import 'package:habr_app/widgets/incrementally_loading_listview.dart';
import 'package:habr_app/widgets/widgets.dart';

import 'package:habr_app/habr_storage/habr_storage.dart';
import '../utils/log.dart';

class ArticlesList extends StatefulWidget {
  ArticlesList({Key key}) : super(key: key);

  @override
  createState() => _ArticlesListState();
}

class _ArticlesListState extends State<ArticlesList> {
  ArticlesStorage store = ArticlesStorage();

  _ArticlesListState() {
    store.changeFlow(PostsFlow.dayTop);
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
                  return Center(child: const CircularItem());
                final preview = store.previews[index];
                return SlidableArchive(
                  child: ArticlePreview(
                    postPreview: preview,
                    onPressed: (articleId) => openArticle(context, articleId),
                  ),
                  onArchive: () => HabrStorage().addArticleInCache(preview.id).then((_) {
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text("${preview.title} скачено"))
                    );
                  }),
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
            widget = LossInternetConnection(onPressReload: store.reload);
            break;
        }
        return widget;
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainMenu(),
      appBar: AppBar(
        title: Text("Articles"),
      ),
      body: bodyWidget(),
    );
  }
}
