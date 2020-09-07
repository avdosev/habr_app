import 'package:flutter/material.dart';
import 'package:habr_app/pages/article.dart';
import 'package:incrementally_loading_listview/incrementally_loading_listview.dart';

import 'package:habr_app/utils/date_to_text.dart';
import '../habr/dto.dart';
import '../habr/api.dart';

import '../utils/log.dart';

class StatisticsFavoritesIcon extends StatelessWidget {
  final int favorites;
  final double size;
  StatisticsFavoritesIcon(this.favorites, {this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.bookmark, size: size, color: Colors.grey,),
        SizedBox(width: 5,),
        Text(favorites.toString()),
      ]
    );
  }
}
class StatisticsScoreIcon extends StatelessWidget {
  final int score;
  final double size;
  StatisticsScoreIcon(this.score, {this.size = 20});

  @override
  Widget build(BuildContext context) {
    var iconText = score.toString();
    if (score > 0) iconText = '+' + iconText;
    final colors = {
      -1: Colors.red[800],
      0 : Colors.grey[600],
      1 : Colors.green[800],
    };
    return Row(
      children: [
        Icon(Icons.equalizer, size: size, color: Colors.grey,),
        SizedBox(width: 5,),
        // Icon(Icons.thumbs_up_down, size: size,), // maybe use this
        Text(iconText, style: TextStyle(color: colors[score.sign])),
      ]
    );
  }
}

class StatisticsViewsIcon extends StatelessWidget {
  final int views;
  final double size;
  StatisticsViewsIcon(this.views, {this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.remove_red_eye, size: size, color: Colors.grey,),
        SizedBox(width: 5,),
        Text(views.toString(),),
      ]
    );
  }
}

class StatisticsCommentsIcon extends StatelessWidget {
  final int comments;
  final double size;
  StatisticsCommentsIcon(this.comments, {this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.forum, size: size, color: Colors.grey,),
        SizedBox(width: 5,),
        Text(comments.toString()),
      ]
    );
  }
}

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
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Row(
              children: [
                Text(dateToStr(_postPreview.publishDate, Localizations.localeOf(context))),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 5,
                  children: [
                    if (_postPreview.author.avatarUrl.length != 0) ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: Image.network(_postPreview.author.avatarUrl, height: 20, width: 20,),
                    ),
                    Text(_postPreview.author.alias),
                  ]
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            SizedBox(height: 7,),
            Text(_postPreview.title,  style: new TextStyle(fontSize: 20.0), overflow: TextOverflow.visible, softWrap: true, textAlign: TextAlign.left),
            SizedBox(height: 10,),
            Text(_postPreview.tags.join(', '), overflow: TextOverflow.ellipsis, textAlign: TextAlign.left),
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatisticsScoreIcon(_postPreview.statistics.score),
                StatisticsViewsIcon(_postPreview.statistics.readingCount),
                StatisticsFavoritesIcon(_postPreview.statistics.favoritesCount),
                StatisticsCommentsIcon(_postPreview.statistics.commentsCount),
              ],
            )
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