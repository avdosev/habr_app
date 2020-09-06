import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habr_app/html_view/html_view.dart';
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
  Post _post;
  Future _initialLoad;

  _ArticlePageState(this.articleId);

  @override
  void initState() {
    super.initState();
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
              return ArticleView(article: _post);
            default:
              return Text('Something went wrong');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Comment', // used by assistive technologies
        child: Icon(Icons.chat_bubble_outline),
        onPressed: null, // TODO: Comments page
      ),
    );

  }
}

class ArticleView extends StatelessWidget {
  final Post article;

  const ArticleView({this.article});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(5),
      children: [
        Text(article.title, style: TextStyle(fontSize: 20)),
        SizedBox(height: 20,),
        HtmlView(article.body)
      ],
    );
  }
}
