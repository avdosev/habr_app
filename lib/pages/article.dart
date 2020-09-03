import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../habr/dto.dart';
import '../habr/api.dart';

import '../log.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Publish"),
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
      children: [
        Text(article.title, style: TextStyle(fontSize: 20)),
        Text(article.body)
      ],
    );
  }
}
