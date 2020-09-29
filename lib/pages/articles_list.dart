import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:habr_app/pages/article.dart';
import 'package:habr_app/widgets/widgets.dart';


import 'package:habr_app/habr_storage/habr_storage.dart';
import '../utils/log.dart';

class ArticlesList extends StatefulWidget {
  ArticlesList({Key key}) : super(key: key);

  @override
  createState() => _ArticlesListState();
}

openArticle(BuildContext context, String articleId) {
  Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ArticlePage(articleId: articleId))
  );
}

class _ArticlesListState extends State<ArticlesList> {
  Future _initialLoad;

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    setState(() {
      _initialLoad = loadPosts(1);
    });
  }

  Future<Either<StorageError, PostPreviews>> loadPosts(int page) async {
    return await HabrStorage().posts(page: page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainMenu(),
      appBar: AppBar(
        title: Text("Articles"),
      ),
      body: FutureBuilder<Either<StorageError, PostPreviews>>(
        future: _initialLoad,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError || snapshot.data.isLeft) {
                return Center(child: LossInternetConnection(onPressReload: reload));
              }
              return Container(
                child: IncrementallyLoadingArticleView(
                  postPreviewBuilder: (context, preview) => SlidableArchive(
                    child: ArticlePreview(
                      postPreview: preview,
                      onPressed: (articleId) => openArticle(context, articleId),
                    ),
                    onArchive: () => HabrStorage().addArticleInCache(preview.id),
                  ),
                  load: (int page) async {
                    final postOrError = await loadPosts(page);
                    return postOrError.unite<PostPreviews>((err) {
                      // TODO: informing user
                      return PostPreviews(
                        previews: [],
                        maxCountPages: -1
                      );
                    }, (posts) => posts);
                  },
                  initPage: snapshot.data.right,
                )
              );
            default:
              return Text('Something went wrong');
          }
        },
      )
    );
  }
}