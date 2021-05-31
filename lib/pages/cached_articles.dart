import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habr_app/utils/page_loaders/preview_loader.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:habr_app/widgets/incrementally_loading_listview.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:habr_app/stores/article_store.dart';
import 'package:habr_app/routing/routing.dart';
import '../stores/loading_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CachedArticlesList extends StatelessWidget {
  CachedArticlesList({Key key}) : super(key: key);

  Widget bodyWidget(BuildContext context, ArticlesStorage store) {
    Widget widget;
    switch (store.firstLoading) {
      case LoadingState.isFinally:
        widget = store.previews.length > 0
            ? IncrementallyLoadingListView(
                itemBuilder: (itemContext, index) {
                  if (index >= store.previews.length && store.loadItems)
                    return Center(child: const CircularItem());
                  final preview = store.previews[index];
                  return SlidableDelete(
                    key: Key("preview_delete_" + preview.id),
                    child: ArticlePreview(
                      key: Key("preview_" + preview.id),
                      postPreview: preview,
                      onPressed: (articleId) => openArticle(context, articleId),
                    ),
                    onDelete: () {
                      final articleId = preview.id;
                      store.removePreview(articleId);
                      HabrStorage()
                          .removeArticleFromCache(articleId)
                          .then((value) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "${preview.title} ${AppLocalizations.of(context).removed}")));
                      });
                    },
                  );
                },
                separatorBuilder: (context, index) => const Hr(),
                itemCount: () =>
                    store.previews.length + (store.loadItems ? 1 : 0),
                loadMore: store.loadNextPage,
                hasMore: store.hasNextPages,
              )
            : Center(child: EmptyContent());
        break;
      case LoadingState.inProgress:
        widget = Center(child: CircularProgressIndicator());
        break;
      case LoadingState.isCorrupted:
        widget = Center(child: EmptyContent());
        break;
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArticlesStorage(CachedPreviewLoader()),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).cachedArticles),
          actions: [
            Builder(builder: (context) {
              final store = context.watch<ArticlesStorage>();
              return IconButton(
                  tooltip: AppLocalizations.of(context).unarchive,
                  icon: const Icon(Icons.unarchive),
                  onPressed: () {
                    store.removeAllPreviews();
                    HabrStorage().removeAllArticlesFromCache();
                  });
            }),
          ],
        ),
        body: Consumer<ArticlesStorage>(
          builder: (context, store, __) => bodyWidget(context, store),
        ),
      ),
    );
  }
}
