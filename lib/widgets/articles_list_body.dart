import 'package:flutter/material.dart';
import 'package:habr_app/stores/habr_storage.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:provider/provider.dart';
import 'package:habr_app/stores/article_store.dart';
import 'package:habr_app/utils/message_notifier.dart';
import 'package:habr_app/app_error.dart';
import 'package:habr_app/stores/loading_state.dart';

import 'adaptive_ui.dart';
import 'incrementally_loading_listview.dart';
import 'hr.dart';
import 'informing/informing.dart';
import 'slidable.dart';
import 'circular_item.dart';
import 'article_preview.dart';

class ArticlesListBody extends StatelessWidget {
  Widget build(BuildContext context) {
    return Consumer<ArticlesStorage>(
      builder: (context, store, _) => _build(store),
    );
  }

  Widget _build(ArticlesStorage store) {
    Widget widget;
    switch (store.firstLoading) {
      case LoadingState.isFinally:
        widget = IncrementallyLoadingListView(
          itemBuilder: (context, index) {
            if (index >= store.previews.length && store.loadItems)
              return const Center(child: CircularItem());
            final preview = store.previews[index];
            final habrStorage =
                Provider.of<HabrStorage>(context, listen: false);
            return DefaultConstraints(
                child: SlidableArchive(
              child: ArticlePreview(
                key: ValueKey("preview_" + preview.id),
                postPreview: preview,
                onPressed: (articleId) => openArticle(context, articleId),
              ),
              onArchive: () => habrStorage.addArticleInCache(preview.id).then(
                  (res) => notifySnackbarText(
                      context, "${preview.title} ${res ? '' : 'не'} скачано")),
            ));
          },
          separatorBuilder: (context, index) =>
              const DefaultConstraints(child: Hr()),
          itemCount: () => store.previews.length + (store.loadItems ? 1 : 0),
          loadMore: store.loadNextPage,
          hasMore: store.hasNextPages,
        );
        break;
      case LoadingState.inProgress:
        widget = Center(child: CircularProgressIndicator());
        break;
      case LoadingState.isCorrupted:
        switch (store.lastError.errCode) {
          case ErrorType.ServerError:
            widget = const Center(child: const LotOfEntropy());
            break;
          default:
            widget = Center(
                child: LossInternetConnection(onPressReload: store.reload));
        }
        break;
    }
    return widget;
  }
}
