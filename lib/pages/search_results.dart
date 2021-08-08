import 'package:flutter/material.dart';
import 'package:habr_app/utils/page_loaders/preview_loader.dart';
import 'package:habr_app/stores/articles_store.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SearchResultListPage extends StatelessWidget {
  final SearchLoader loader;
  SearchResultListPage({Key key, @required this.loader}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArticlesStorage(loader),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text("${AppLocalizations.of(context).search} ${loader.query}"),
        ),
        body: ArticlesListBody(),
      ),
    );
  }
}
