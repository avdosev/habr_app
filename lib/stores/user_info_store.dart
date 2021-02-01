import 'package:mobx/mobx.dart';

import 'package:habr_app/app_error.dart';
import 'package:habr_app/models/author_info.dart';
import 'package:habr_app/stores/loading_state.dart';
import 'package:habr_app/habr/api.dart';

part 'user_info_store.g.dart';

class UserInfoStorage = UserInfoStorageBase with _$UserInfoStorage;

abstract class UserInfoStorageBase with Store {
  @observable
  LoadingState loadingState;

  AuthorInfo info;
  AppError lastError;

  @action
  Future<void> loadInfo(String username) async {
    loadingState = LoadingState.inProgress;
    final userInfo = await Habr().userInfo(username);
    userInfo.either((left) {
      loadingState = LoadingState.isCorrupted;
      lastError = left;
    }, (right) {
      loadingState = LoadingState.isFinally;
      info = right;
    });
  }
}
