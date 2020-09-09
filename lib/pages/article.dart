import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:habr_app/widgets/html_view.dart';
import 'package:habr_app/widgets/hide_floating_action_button.dart';
import 'package:share/share.dart';
import '../habr/dto.dart';
import '../habr/api.dart';

import '../utils/log.dart';

class ArticlePage extends StatefulWidget {
  ArticlePage({Key key, this.articleId}) : super(key: key);

  final String articleId;

  @override
  createState() => _ArticlePageState(articleId);
}

class _ArticlePageState extends State<ArticlePage> {
  final String articleId;
  ValueNotifier<bool> showFloatingActionButton = ValueNotifier(true);
  Post _post;
  Future _initialLoad;
  ScrollController _controller = ScrollController();

  _ArticlePageState(this.articleId);

  @override
  void initState() {
    super.initState();
    _controller.addListener(floatingButtonShowListener);
    _initialLoad = Habr().article(articleId).then((val) {
      setState(() {
        _post = val;
      });
    }).catchError(logError);
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
              return ArticleView(article: _post, controller: _controller,);
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
            child: Icon(Icons.chat_bubble_outline),
            onPressed: () {}, // TODO: Comments page
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
      padding: EdgeInsets.all(5),
      controller: controller,
      children: [
        Text(article.title, style: TextStyle(fontSize: 20)),
        SizedBox(height: 20,),
        HtmlView(article.body)
      ],
    );
  }
}
