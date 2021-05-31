import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habr_app/stores/filters_store.dart';
import 'package:habr_app/utils/filters/article_preview_filters.dart';
import 'package:habr_app/utils/page_loaders/preview_loader.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:habr_app/stores/article_store.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ArticlesList extends StatelessWidget {
  ArticlesList({Key key}) : super(key: key);

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
      body: ChangeNotifierProvider(
        create: (context) {
          return ArticlesStorage(FlowPreviewLoader(PostsFlow.dayTop),
              filter: AnyFilterCombine(FiltersStorage().getAll().toList()));
        },
        builder: (context, child) => ArticlesListBody(),
      ),
    );
  }
}
