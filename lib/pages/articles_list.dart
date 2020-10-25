import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:habr_app/widgets/widgets.dart';

import 'package:habr_app/habr_storage/habr_storage.dart';
import '../utils/log.dart';

class ArticlesList extends StatefulWidget {
  ArticlesList({Key key}) : super(key: key);

  @override
  createState() => _ArticlesListState();
}

class _ArticlesListState extends State<ArticlesList> {
  Future<Either<StorageError, PostPreviews>> _initialLoad;

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    setState(() {
      _initialLoad = loadFirstPage();
    });
  }

  Future<Either<StorageError, PostPreviews>> loadFirstPage() async {
    return await HabrStorage().posts(page: 1);
  }

  Future<PostPreviews> loadPosts(int page) async {
    final postOrError = await HabrStorage().posts(page: page);
    return postOrError.unite<PostPreviews>((err) {
      // TODO: informing user
      return PostPreviews(previews: [], maxCountPages: -1);
    }, (posts) => posts);
  }

  addArticleInCache(String id) {
    HabrStorage().addArticleInCache(id);
  }

  Widget errorWidget() {
    return Center(
        child: LossInternetConnection(onPressReload: reload));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainMenu(),
      appBar: AppBar(
        title: Text("Articles"),
      ),
      body: LoadBuilder<StorageError, PostPreviews>(
        future: _initialLoad,
        onRightBuilder: (context, data) =>
          IncrementallyLoadingArticleView(
            postPreviewBuilder: (context, preview) => SlidableArchive(
              child: ArticlePreview(
                postPreview: preview,
                onPressed: (articleId) => openArticle(context, articleId),
              ),
              onArchive: () => addArticleInCache(preview.id),
            ),
            load: loadPosts,
            initPage: data,
          ),
        onErrorBuilder: (context, err) {
          logError(err);
          return errorWidget();
        },
      )
    );
  }
}
