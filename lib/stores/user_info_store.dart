import 'package:flutter/foundation.dart';

import 'package:habr_app/app_error.dart';
import 'package:habr_app/models/author_info.dart';
import 'package:habr_app/stores/loading_state.dart';
import 'package:habr_app/habr/api.dart';

class UserInfoStorage with ChangeNotifier {
  UserInfoStorage(this.username);

  LoadingState loadingState;
  String username;
  AuthorInfo info;
  AppError lastError;

  void loadInfo() async {
    loadingState = LoadingState.inProgress;
    notifyListeners();
    final userInfo = await Habr().userInfo(username);
    userInfo.either((left) {
      loadingState = LoadingState.isCorrupted;
      lastError = left;
    }, (right) {
      loadingState = LoadingState.isFinally;
      info = right;
    });
    notifyListeners();
  }
}
