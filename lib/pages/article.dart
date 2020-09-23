import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:either_dart/either.dart';
import 'package:habr_app/pages/comments.dart';
import 'package:habr_app/utils/date_to_text.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:share/share.dart';
import 'dart:math' as math;
import '../habr/dto.dart';
import '../habr/api.dart';

import '../utils/log.dart';

class ArticlePage extends StatefulWidget {
  final String articleId;

  ArticlePage({Key key, this.articleId}) : super(key: key);

  @override
  createState() => _ArticlePageState();
}

void openCommentsPage(BuildContext context, String articleId) {
  Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CommentsPage(articleId: articleId,))
  );
}

class _ArticlePageState extends State<ArticlePage> {
  String get articleId => widget.articleId;
  ValueNotifier<bool> showFloatingActionButton = ValueNotifier(true);
  ScrollController _controller = ScrollController();

  _ArticlePageState();

  @override
  void initState() {
    super.initState();
    _controller.addListener(floatingButtonShowListener);
  }

  Future shareArticle(BuildContext context) async {
    final RenderBox box = context.findRenderObject();
    await Share.share('https://habr.com/post/$articleId',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Publish"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => shareArticle(context),
          )
        ],
      ),
      body: LoadableArticleView(articleId: articleId, controller: _controller,),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: showFloatingActionButton,
        builder: (BuildContext context, bool value, Widget child) =>
          HideFloatingActionButton(
            tooltip: 'Comments',
            visible: value,
            child: const Icon(Icons.chat_bubble_outline),
            onPressed: () => openCommentsPage(context, articleId),
            duration: const Duration(milliseconds: 300),
          )
      )
    );
  }


  void floatingButtonShowListener() {
    final needShow = _controller.position.userScrollDirection == ScrollDirection.forward;
    if (needShow != showFloatingActionButton.value)
       showFloatingActionButton.value = needShow;
  }

  @override
  void dispose() {
    _controller.removeListener(floatingButtonShowListener);
    super.dispose();
  }
}

class ArticleInfo extends StatelessWidget {
  final Post article;

  const ArticleInfo({this.article});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(dateToStr(article.publishDate, Localizations.localeOf(context))),
            SmallAuthorPreview(article.author),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        const SizedBox(height: 7,),
        Text(article.title, style: TextStyle(fontSize: 24), textAlign: TextAlign.center,),
      ],
    );
  }
}

class LoadableArticleView extends StatefulWidget {
  final String articleId;
  final ScrollController controller;

  LoadableArticleView({this.articleId, this.controller});

  @override
  State<StatefulWidget> createState() => _LoadableArticleViewState();
}

class _LoadableArticleViewState extends State<LoadableArticleView> {
  Future<Either<StorageError, Post>> _initialLoad;
  String get articleId => widget.articleId;

  _LoadableArticleViewState();

  @override
  initState() {
    super.initState();
    _initialLoad = loadArticle();
  }

  reload() async {
    setState(() {
      _initialLoad = loadArticle();
    });
  }

  Future<Either<StorageError, Post>> loadArticle() async {
    return HabrStorage().article(articleId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialLoad,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            if (snapshot.hasError || snapshot.data.isLeft)
             return Center(child: LossInternetConnection(onPressReload: reload));
            return ArticleView(article: snapshot.data.right, controller: widget.controller,);
          default:
            return Text('Something went wrong');
        }
      },
    );
  }
}

class ArticleView extends StatelessWidget {
  final Post article;
  final ScrollController controller;

  const ArticleView({this.article, this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10).copyWith(bottom: 20),
      controller: controller,
      children: [
        ArticleInfo(article: article,),
        SizedBox(height: 30,),
        HtmlView(article.body),
        SizedBox(height: 20,),
        CommentsButton(onPressed: () => openCommentsPage(context, article.id),)
      ],
    );
  }
}
