import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:either_dart/either.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:habr_app/stores/app_settings.dart';
import 'package:habr_app/utils/date_to_text.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:habr_app/app_error.dart';
import 'package:habr_app/models/comment.dart';
import '../utils/log.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommentsPage extends StatefulWidget {
  final String articleId;

  CommentsPage({Key key, this.articleId}) : super(key: key);

  @override
  createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  String get articleId => widget.articleId;
  Future<Either<AppError, List<Comment>>> _initialLoad;

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

  Future<Either<AppError, List<Comment>>> loadComments() async {
    return HabrStorage()
        .comments(articleId)
        .then((value) => value
            .map<List<Comment>>((right) => flatCommentsTree(right).toList()))
        .catchError(logError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).comments),
        actions: [],
      ),
      body: LoadBuilder(
        future: _initialLoad,
        onRightBuilder: (context, comments) {
          if (comments.length == 0)
            return Center(
              child: EmptyContent(),
            );
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) => Container(
              padding: const EdgeInsets.only(left: 7, right: 7),
              child: LeveledCommentsView(comments[index]),
            ),
            itemCount: comments.length,
          );
        },
        onErrorBuilder: (context, err) =>
            Center(child: LossInternetConnection(onPressReload: reload)),
      ),
    );
  }
}

class LeveledCommentsView extends StatelessWidget {
  final Comment comment;

  LeveledCommentsView(this.comment);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    Widget widget = CommentView(comment);
    for (int i = 0; i < min(comment.level, 10); i++) {
      widget = Container(
        decoration: BoxDecoration(
            border: Border(
                left: BorderSide(
          color: themeData.primaryColor,
          width: 1.1,
        ))),
        padding: const EdgeInsets.only(left: 6),
        child: widget,
      );
    }
    return widget;
  }
}

Iterable<Comment> flatCommentsTree(Comments comments) sync* {
  final stack = <int>[]; // так будет меньше аллокаций
  for (final thread in comments.threads) {
    final threadStart = comments.comments[thread];
    yield threadStart;
    stack.addAll(threadStart.children.reversed);
    while (stack.isNotEmpty) {
      final currentId = stack.removeLast();
      final comment = comments.comments[currentId];
      stack.addAll(comment.children.reversed);
      yield comment;
    }
  }
}

class CommentView extends StatelessWidget {
  final Comment comment;

  CommentView(this.comment);

  @override
  Widget build(BuildContext context) {
    if (comment.banned) {
      return Text(AppLocalizations.of(context).bannedComment);
    }
    final appSettings = context.watch<AppSettings>();
    final textAlign = appSettings.commentTextAlign;
    return Padding(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  child: SmallAuthorPreview(comment.author),
                  onTap: () => openUser(context, comment.author.alias),
                ),
                Text(dateToStr(
                    (comment.timePublished), Localizations.localeOf(context))),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            const SizedBox(
              height: 10,
            ),
            HtmlView.unparsed(
              comment.message,
              textAlign: textAlign,
            ),
            // TODO: buttons
          ],
        ));
  }
}
