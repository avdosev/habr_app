import 'package:flutter/material.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:habr_app/models/models.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:habr_app/stores/bookmarks_store.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class BookmarksArticlesList extends StatefulWidget {
  BookmarksArticlesList({Key key}) : super(key: key);

  @override
  createState() => _BookmarksArticlesListState();
}

class _BookmarksArticlesListState extends State<BookmarksArticlesList> {
  final store = BookmarksStore();

  Widget buildItem(BuildContext context, PostPreview preview) {
    return SlidableArchiveDelete(
      child: ArticlePreview(
        key: Key("preview_" + preview.id),
        postPreview: preview,
        onPressed: (articleId) => openArticle(context, articleId),
      ),
      onDelete: () {
        store.removeBookmark(preview.id);
      },
      onArchive: () {
        HabrStorage().addArticleInCache(preview.id);
      },
    );
  }

  buildBody(BuildContext bodyContext) {
    return ValueListenableBuilder<Box<PostPreview>>(
      valueListenable: store.bookmarks(),
      builder: (context, box, _) {
        final bookmarks = box.values;
        final previews = bookmarks.map((e) => buildItem(context, e)).toList();
        if (previews.isEmpty) return Center(child: EmptyContent());
        return ListView(
          children: previews,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).bookmarks),
      ),
      body: buildBody(context),
    );
  }
}
