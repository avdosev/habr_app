import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:either_dart/either.dart';
import 'package:habr_app/pages/comments.dart';
import 'package:habr_app/widgets/html_view.dart';
import 'package:habr_app/widgets/hide_floating_action_button.dart';
import 'package:habr_app/widgets/internet_error_view.dart';
import 'package:share/share.dart';
import '../habr/dto.dart';
import '../habr/api.dart';

import '../utils/log.dart';

class ArticlePage extends StatefulWidget {
  final String articleId;

  ArticlePage({Key key, this.articleId}) : super(key: key);

  @override
  createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  String get articleId => widget.articleId;
  ValueNotifier<bool> showFloatingActionButton = ValueNotifier(true);
  Future<Either<StorageError, Post>> _initialLoad;
  ScrollController _controller = ScrollController();

  _ArticlePageState();

  @override
  void initState() {
    super.initState();
    _controller.addListener(floatingButtonShowListener);
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
      body: FutureBuilder(
        future: _initialLoad,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              final widget = (snapshot.hasError || snapshot.data.isLeft) ?
                Center(child: LossInternetConnection(onPressReload: reload)) :
                ArticleView(article: snapshot.data.right, controller: _controller,);
              return widget;
            default:
              return Text('Something went wrong');
          }
        },
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: showFloatingActionButton,
        builder: (BuildContext context, bool value, Widget child) =>
          HideFloatingActionButton(
            tooltip: 'Comments',
            visible: value,
            child: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CommentsPage(articleId: articleId,))
            ),
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

class ArticleView extends StatelessWidget {
  final Post article;
  final ScrollController controller;

  const ArticleView({this.article, this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      controller: controller,
      children: [
        Text(article.title, style: TextStyle(fontSize: 20)),
        SizedBox(height: 20,),
        HtmlView(article.body)
      ],
    );
  }
}
