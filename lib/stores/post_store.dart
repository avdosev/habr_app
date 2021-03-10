import 'package:mobx/mobx.dart';

import 'package:habr_app/app_error.dart';
import 'package:habr_app/models/post.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:habr_app/stores/loading_state.dart';
import 'package:habr_app/utils/html_to_json.dart';

part 'post_store.g.dart';

class PostStorage = PostStorageBase with _$PostStorage;

abstract class PostStorageBase with Store {
  @observable
  LoadingState loadingState;

  String _id; // Article id
  ParsedPost post;
  AppError lastError;

  set articleId(String val) {
    _id = val;
    reload();
  }

  String get articleId => _id;

  @action
  Future reload() async {
    loadingState = LoadingState.inProgress;
    final postOrError = await HabrStorage().article(_id);
    postOrError.map(
      (right) => ParsedPost(
        id: right.id,
        title: right.title,
        author: right.author,
        publishDate: right.publishDate,
        parsedBody: htmlAsParsedJson(right.body),
      ),
    ).either((left) {
      loadingState = LoadingState.isCorrupted;
      lastError = left;
    }, (right) {
      loadingState = LoadingState.isFinally;
      post = right;
    });
  }
}
