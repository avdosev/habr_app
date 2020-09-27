import 'package:flutter/material.dart';
import 'package:habr_app/pages/article.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:incrementally_loading_listview/incrementally_loading_listview.dart';

import 'package:habr_app/utils/date_to_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
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
    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Row(
              children: [
                Text(dateToStr(_postPreview.publishDate, Localizations.localeOf(context))),
                SmallAuthorPreview(_postPreview.author),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            const SizedBox(height: 7,),
            Text(_postPreview.title,  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600), overflow: TextOverflow.visible, softWrap: true, textAlign: TextAlign.left),
            const SizedBox(height: 10,),
            Text(_postPreview.tags.join(', '), overflow: TextOverflow.ellipsis, textAlign: TextAlign.left),
            const SizedBox(height: 5,),
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
                      child: ArticlePreview(previews[index]),
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