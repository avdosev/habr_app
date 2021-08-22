import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habr_app/stores/filters_store.dart';
import 'package:habr_app/utils/filters/article_preview_filters.dart';
import 'package:habr_app/utils/page_loaders/preview_loader.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:habr_app/stores/articles_store.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:habr_app/stores/habr_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ArticlesList extends StatelessWidget {
  ArticlesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final drawerIsPartOfBody = width > 1000;
    return Scaffold(
      drawer: drawerIsPartOfBody ? null : MainMenu(),
      appBar: AppBar(
        title: Text("Habr"),
        actions: [
          IconButton(
              tooltip: AppLocalizations.of(context)!.search,
              icon: const Icon(Icons.search),
              onPressed: () => openSearch(context))
        ],
      ),
      body: ChangeNotifierProvider(
        create: (context) {
          final habrStorage = Provider.of<HabrStorage>(context, listen: false);
          return ArticlesStorage(
              FlowPreviewLoader(flow: PostsFlow.dayTop, storage: habrStorage),
              filter: AnyFilterCombine(FiltersStorage().getAll().toList()));
        },
        child: Row(
          children: [
            if (drawerIsPartOfBody) DesktopHomeMenu(),
            Expanded(child: ArticlesListBody()),
          ],
        ),
      ),
    );
  }
}
