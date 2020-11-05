import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:habr_app/article_preview_loader/preview_loader.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
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
  final store = ArticlesStorage(CachedPreviewLoader());

  Widget bodyWidget() {
    return Observer(
      builder:(context) {
        Widget widget;
        switch (store.firstLoading) {
          case LoadingState.isFinally:
            widget = store.previews.length > 0 ? SeparatedIncrementallyLoadingListView(
              itemBuilder: (context, index) {
                if (index >= store.previews.length && store.loadItems)
                  return Center(child: const CircularItem());
                final preview = store.previews[index];
                return SlidableDelete(
                  key: Key(preview.id),
                  child: ArticlePreview(
                    postPreview: preview,
                    onPressed: (articleId) => openArticle(context, articleId),
                  ),
                  onDelete: () {
                    final articleId = preview.id;
                    store.removePreview(articleId);
                    HabrStorage().removeArticleFromCache(articleId)
                      .then((value) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text("${preview.title} удалено"))
                        );
                      });
                  },
                );
              },
              separatorBuilder: (context, index) => const Hr(),
              itemCount: () => store.previews.length + (store.loadItems ? 1 : 0),
              loadMore: store.loadNextPage,
              hasMore: store.hasNextPages,
            ) : Center(child: EmptyContent());
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
          actions: [
            IconButton(
              tooltip: "Unarchive",
              icon: const Icon(Icons.unarchive),
              onPressed: () {
                store.removeAllPreviews();
                HabrStorage().removeAllArticlesFromCache();
              }
            )
          ],
        ),
        body: bodyWidget()
    );
  }
}