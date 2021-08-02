import 'package:flutter/foundation.dart';

import 'package:habr_app/app_error.dart';
import 'package:habr_app/models/post.dart';
import 'package:habr_app/stores/habr_storage.dart';
import 'package:habr_app/stores/loading_state.dart';
import 'package:habr_app/utils/html_to_json.dart';
import 'package:either_dart/either.dart';

class PostStorage with ChangeNotifier {
  PostStorage(this._id, {@required this.storage});

  final HabrStorage storage;

  LoadingState loadingState;

  String _id; // Article id
  ParsedPost post;
  AppError lastError;

  set articleId(String val) {
    _id = val;
    reload();
  }

  String get articleId => _id;

  void reload() {
    loadingState = LoadingState.inProgress;
    storage
        .article(_id)
        .mapRight(
          (right) => ParsedPost(
            id: right.id,
            title: right.title,
            author: right.author,
            publishDate: right.publishDate,
            parsedBody: htmlAsParsedJson(right.body),
          ),
        )
        .either((left) {
      loadingState = LoadingState.isCorrupted;
      lastError = left;
    }, (right) {
      loadingState = LoadingState.isFinally;
      post = right;
    }).then((value) => notifyListeners());
  }
}
