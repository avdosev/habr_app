import 'package:flutter/material.dart';
import 'package:either_dart/either.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:habr_app/utils/date_to_text.dart';
import 'package:habr_app/widgets/widgets.dart';

import '../utils/log.dart';

class CommentsPage extends StatefulWidget {
  final String articleId;

  CommentsPage({Key key, this.articleId}) : super(key: key);

  @override
  createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  String get articleId => widget.articleId;
  Future<Either<StorageError, Comments>> _initialLoad;

  _CommentsPageState();

  @override
  void initState() {
    super.initState();
    _initialLoad = loadComments();
  }

  reload() async {
    setState(() {
      _initialLoad = loadComments();
    });
  }

  Future<Either<StorageError, Comments>> loadComments() async {
    return HabrStorage().comments(articleId).catchError(logError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Comments"),
          actions: [

          ],
        ),
        body: FutureBuilder<Either<StorageError, Comments>>(
          future: _initialLoad,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                Widget widget;
                if (snapshot.hasError || snapshot.data.isLeft) {
                  widget = Center(
                      child: LossInternetConnection(onPressReload: reload));
                } else if (snapshot.data.right.threads.length == 0) {
                  widget = Center(
                    child: EmptyContent(),
                  );
                } else {
                  widget = ListView.builder(
                    itemBuilder: (BuildContext context, int index) =>
                        Container(
                          padding: const EdgeInsets.only(
                              top: 5, bottom: 5, left: 7, right: 7),
                          child: CommentsTree(snapshot.data.right,
                              snapshot.data.right.threads[index]),
                        ),
                    itemCount: snapshot.data.right.threads.length,
                  );
                }
                return widget;
              default:
                return Text('Something went wrong');
            }
          },
        ),
    );
  }
}

class CommentsTree extends StatelessWidget {
  final Comments comments;
  final int currentId;
  CommentsTree(this.comments, this.currentId);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Column(
        children: [
          CommentView(comments.comments[currentId]),
          const SizedBox(height: 5,),
          if (comments.comments[currentId].children.length != 0)
            Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(
                  color: themeData.primaryColor,
                  width: 1.1,
                ))
              ),
              padding: const EdgeInsets.only(left: 6),
              child: Column(
                children: comments.comments[currentId].children.map<Widget>(
                        (childId) => CommentsTree(comments, childId)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class CommentView extends StatelessWidget {
  final Comment comment;
  CommentView(this.comment);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          SmallAuthorPreview(comment.author),
          Text(dateToStr((comment.timePublished), Localizations.localeOf(context))),
        ], mainAxisAlignment: MainAxisAlignment.spaceBetween,),
        const SizedBox(height: 5,),
        HtmlView(comment.message),
        // TODO: buttons
      ],
    );
  }
}