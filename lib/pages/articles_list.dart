import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:habr_app/app_error.dart';
import 'package:habr_app/stores/filters_store.dart';
import 'package:habr_app/utils/filters/article_preview_filters.dart';
import 'package:habr_app/utils/page_loaders/preview_loader.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:habr_app/stores/article_store.dart';
import 'package:habr_app/widgets/incrementally_loading_listview.dart';
import 'package:habr_app/widgets/widgets.dart';
import '../stores/loading_state.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ArticlesList extends StatefulWidget {
  ArticlesList({Key key}) : super(key: key);

  @override
  createState() => _ArticlesListState();
}

Widget bodyWidget(ArticlesStorage store) {
  return Observer(builder: (context) {
    Widget widget;
    switch (store.firstLoading) {
      case LoadingState.isFinally:
        widget = IncrementallyLoadingListView(
          itemBuilder: (context, index) {
            if (index >= store.previews.length && store.loadItems)
              return Center(child: const CircularItem());
            final preview = store.previews[index];
            return SlidableArchive(
              child: ArticlePreview(
                key: ValueKey("preview_" + preview.id),
                postPreview: preview,
                onPressed: (articleId) => openArticle(context, articleId),
              ),
              onArchive: () =>
                  HabrStorage().addArticleInCache(preview.id).then((res) {
                Scaffold.of(context).showSnackBar(SnackBar(
                    content:
                        Text("${preview.title} ${res ? '' : 'не'} скачено")));
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
  });
}

class _ArticlesListState extends State<ArticlesList> {
  ArticlesStorage store = ArticlesStorage(FlowPreviewLoader(PostsFlow.dayTop),
      filter: AnyFilterCombine(FiltersStorage().getAll().toList()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainMenu(),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).articles),
        actions: [
          IconButton(
              tooltip: AppLocalizations.of(context).search,
              icon: const Icon(Icons.search),
              onPressed: () => openSearch(context))
        ],
      ),
      body: bodyWidget(store),
    );
  }
}
