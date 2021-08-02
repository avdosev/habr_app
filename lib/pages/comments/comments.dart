import 'dart:math';
import 'package:flutter/material.dart';
import 'package:habr_app/stores/loading_state.dart';
import 'package:provider/provider.dart';
import 'package:habr_app/stores/habr_storage.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:habr_app/stores/app_settings.dart';
import 'package:habr_app/utils/date_to_text.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:habr_app/app_error.dart';
import 'package:habr_app/models/comment.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'components/comments_store.dart';

class CommentsPage extends StatelessWidget {
  final String articleId;

  CommentsPage({Key key, this.articleId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final habrStorage = Provider.of<HabrStorage>(context, listen: false);
        final store = CommentsStorage(articleId, storage: habrStorage);
        store.reload();
        return store;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).comments),
          actions: [],
        ),
        body: Consumer<CommentsStorage>(
          builder: (context, store, _) => buildBody(context, store),
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context, CommentsStorage commentsStorage) {
    switch (commentsStorage.loadingState) {
      case LoadingState.inProgress:
        return const Center(child: const CircularProgressIndicator());
      case LoadingState.isFinally:
        final comments = commentsStorage.comments;
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
      case LoadingState.isCorrupted:
        switch (commentsStorage.lastError.errCode) {
          case ErrorType.ServerError:
            return const Center(child: const LotOfEntropy());
          default:
            return Center(
              child: LossInternetConnection(
                onPressReload: () => commentsStorage.reload(),
              ),
            );
        }
        break;
      default:
        throw UnsupportedError(
            "Loading state ${commentsStorage.loadingState} not supported");
    }
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

class CommentView extends StatelessWidget {
  final Comment comment;

  CommentView(this.comment);

  @override
  Widget build(BuildContext context) {
    if (comment.banned) {
      return Text(AppLocalizations.of(context).bannedComment);
    }
    final appSettings = Provider.of<AppSettings>(context, listen: false);
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
