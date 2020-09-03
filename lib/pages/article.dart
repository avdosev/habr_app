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
  Future _initialLoad;

  _ArticlePageState(this.articleId);

  @override
  void initState() {
    super.initState();
    _initialLoad = Habr().article(articleId).catchError(logError);
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
                return Text('Download');
              default:
                return Text('Something went wrong');
            }
          },
        )
    );
  }
}

