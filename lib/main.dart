import 'package:flutter/material.dart';
import 'habr/dto.dart';
import 'habr/api.dart';

void main() {
  runApp(MyApp());
}

void logError(Error e) {
  print(e.toString());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habr',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  createState() => _ArticlesListState();
}

class ArticlePreview extends StatelessWidget {
  final PostPreview _postPreview;

  ArticlePreview(this._postPreview);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        children: [
          Row(
            children: [
              Text(_postPreview.publishDate.toString()),
              Text(_postPreview.author.alias)
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          Text(_postPreview.title,  style: new TextStyle(fontSize: 20.0), overflow: TextOverflow.visible, softWrap: true, textAlign: TextAlign.left),
          Text(_postPreview.tags.join(', '), overflow: TextOverflow.ellipsis, textAlign: TextAlign.left)
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      )
    );
  }
}

class _ArticlesListState extends State<MyHomePage> {
  List<PostPreview> previews = [];

  _ArticlesListState() {
    Habr().posts().then((value) {
      setState(() {
        previews.addAll(value);
      });
    }).catchError((e) {
      logError(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(5.0),
        child: ListView.separated(
          itemCount: previews.length,
          itemBuilder: (BuildContext context, int index) {
            return ArticlePreview(previews[index]);
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        ),
      ),
    );
  }
}
