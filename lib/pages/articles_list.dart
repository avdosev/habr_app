import 'package:flutter/material.dart';
import 'package:habr_app/pages/article.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:incrementally_loading_listview/incrementally_loading_listview.dart';


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

class CircularItem extends StatelessWidget {
  const CircularItem();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: const CircularProgressIndicator()
    );
  }
}

class _ArticlesListState extends State<ArticlesList> {
  int pages = 0;
  int maxPages = -1;
  bool loadingItems = false;
  List<PostPreview> previews = [];
  Future _initialLoad;

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    setState(() {
      pages = 0;
      maxPages = -1;
      loadingItems = false;
      previews = [];
      _initialLoad = _loadPosts(pages+1);
    });
  }

  Future _loadPosts(int page) {
    return HabrStorage().posts(page: page).then((valueOrError) {
      if (valueOrError.isLeft) return; // TODO: обработка ошибки
      final value = valueOrError.right;
      setState(() {
        previews.addAll(value.previews);
        maxPages = value.maxCountPages;
        pages += 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainMenu(),
      appBar: AppBar(
        title: Text("Articles"),
      ),
      body: FutureBuilder(
        future: _initialLoad,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError || previews.length == 0) { // TODO: Null using because loadPost not work with isLeft
                return Center(child: LossInternetConnection(onPressReload: reload));
              }
              return Container(
                child: IncrementallyLoadingListView(
                  itemCount: () => previews.length,
                  hasMore: () => pages < maxPages,
                  itemBuilder: (BuildContext context, int index) {
                    final preview = SlidableArchive(
                      child: ArticlePreview(
                        postPreview: previews[index],
                        onPressed: (articleId) => openArticle(context, articleId),
                      ),
                      onArchive: () => HabrStorage().addArticleInCache(previews[index].id),
                    );
                    final loadingInProgress = ((loadingItems ?? false) && index == previews.length - 1);
                    return Column(
                      children: [
                        preview,
                        if (index != previews.length-1 || loadingInProgress) const Divider(),
                        if (loadingInProgress) const CircularItem()
                      ]
                    );
                  },
                  loadMore: () => _loadPosts(pages+1),
                  onLoadMore: () {
                    setState(() {
                      loadingItems = true;
                    });
                  },
                  onLoadMoreFinished: () {
                    setState(() {
                      loadingItems = false;
                    });
                  },
                  // separatorBuilder: (BuildContext context, int index) => const Divider(),
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