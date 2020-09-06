import 'package:flutter/material.dart';
import 'package:habr_app/pages/article.dart';
import 'package:incrementally_loading_listview/incrementally_loading_listview.dart';

import 'package:habr_app/utils/date_to_text.dart';
import '../habr/dto.dart';
import '../habr/api.dart';

import '../utils/log.dart';

class ArticlesList extends StatefulWidget {
  ArticlesList({Key key}) : super(key: key);

  @override
  createState() => _ArticlesListState();
}

class ArticlePreview extends StatelessWidget {
  final PostPreview _postPreview;

  ArticlePreview(this._postPreview);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(5.0),
        child: new Column(
          children: [
            Row(
              children: [
                Text(dateToStr(_postPreview.publishDate, Localizations.localeOf(context))),
                Text(_postPreview.author.alias)
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            Text(_postPreview.title,  style: new TextStyle(fontSize: 20.0), overflow: TextOverflow.visible, softWrap: true, textAlign: TextAlign.left),
            Text(_postPreview.tags.join(', '), overflow: TextOverflow.ellipsis, textAlign: TextAlign.left)
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        )
      ),
      onLongPress: () {}, // TODO: Настройки поста при долгом нажатии
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ArticlePage(articleId: _postPreview.id))
        );
      },
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
    _initialLoad = _loadPosts(pages+1);
  }

  Future _loadPosts(int page) {
    return Habr().posts().then((value) {
      setState(() {
        previews.addAll(value.previews);
        maxPages = value.maxCountPages;
        pages += 1;
      });
    }).catchError(logError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              return Container(
                child:
                  IncrementallyLoadingListView(
                    itemCount: () => previews.length,
                    hasMore: () => pages < maxPages,
                    itemBuilder: (BuildContext context, int index) {
                      final preview = ArticlePreview(previews[index]);
                      Widget item = ((loadingItems ?? false) && index == previews.length - 1) ?
                        Column(
                          children: [
                            preview,
                            CircularProgressIndicator()
                          ]
                        ) :
                        Column(children: [
                          preview,
                          const Divider()
                        ]);
                      return item;
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