import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:habr_app/pages/article.dart';
import 'package:habr_app/utils/log.dart';
import 'package:habr_app/widgets/widgets.dart';

import 'package:habr_app/habr_storage/habr_storage.dart';
import './articles_list.dart' show openArticle;

class CachedArticlesList extends StatefulWidget {
  CachedArticlesList({Key key}) : super(key: key);

  @override
  createState() => _CachedArticlesListState();
}

class _CachedArticlesListState extends State<CachedArticlesList> {
  Future<Either<StorageError, PostPreviews>> _initialLoad;

  @override
  void initState() {
    super.initState();
    _initialLoad = loadFirstPage();
  }

  Future<Either<StorageError, PostPreviews>> loadFirstPage() async {
    return await HabrStorage().posts(page: 1, flow: PostsFlow.saved);
  }

  Future<PostPreviews> loadPosts(int page) async {
    final postOrError = await HabrStorage().posts(page: page, flow: PostsFlow.saved);
    return postOrError.unite<PostPreviews>((err) {
      // TODO: informing user
      return PostPreviews(previews: [], maxCountPages: -1);
    }, (posts) => posts);
  }

  removeArticleFromCache(String id) {
    // HabrStorage().addArticleInCache(id);
  }

  Widget errorWidget() {
    return Center(
        child: EmptyContent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Cached articles"),
        ),
        body: LoadBuilder(
          future: _initialLoad,
          onRightBuilder: (context, data) =>
              IncrementallyLoadingArticleView(
                postPreviewBuilder: (context, preview) => ArticlePreview(
                  postPreview: preview,
                  onPressed: (articleId) => openArticle(context, articleId),
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