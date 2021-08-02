import 'package:flutter/foundation.dart';

import 'package:habr_app/app_error.dart';
import 'package:habr_app/models/comment.dart';
import 'package:habr_app/stores/habr_storage.dart';
import 'package:habr_app/stores/loading_state.dart';
import 'package:either_dart/either.dart';
import 'package:habr_app/utils/log.dart';

class CommentsStorage with ChangeNotifier {
  CommentsStorage(this._id, {@required this.storage});

  final HabrStorage storage;

  LoadingState loadingState;

  String _id; // Article id
  List<Comment> comments;
  AppError lastError;

  set articleId(String val) {
    _id = val;
    reload();
  }

  String get articleId => _id;

  void reload() {
    loadingState = LoadingState.inProgress;
    storage.comments(_id).either(
      (left) {
        loadingState = LoadingState.isCorrupted;
        lastError = left;
      },
      (right) {
        comments = flatCommentsTree(right).toList();
        loadingState = LoadingState.isFinally;
      },
    ).catchError((err) {
      logError(err);
      loadingState = LoadingState.isCorrupted;
    }).then((_) => notifyListeners());
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
