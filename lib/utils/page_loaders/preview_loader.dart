import 'package:either_dart/either.dart';

import 'package:habr_app/models/post_preview.dart';
import 'package:habr_app/habr/habr.dart';
import 'package:habr_app/stores/habr_storage.dart';
import 'package:habr_app/pages/pages.dart';
import 'package:habr_app/app_error.dart';
import 'page_loader.dart';

export 'page_loader.dart';

class CachedPreviewLoader extends FlowPreviewLoader {
  final HabrStorage storage;
  CachedPreviewLoader({required this.storage})
      : super(flow: PostsFlow.saved, storage: storage);
}

class FlowPreviewLoader extends PageLoader<Either<AppError, PostPreviews>> {
  final PostsFlow flow;
  final HabrStorage storage;

  FlowPreviewLoader({required this.flow, required this.storage});

  Future<Either<AppError, PostPreviews>> load(int page) {
    return storage.posts(page: page, flow: flow);
  }
}

class SearchLoader extends PageLoader<Either<AppError, PostPreviews>> {
  final String query;
  final Order order;

  SearchLoader(SearchData info)
      : query = info.query,
        order = info.order;

  Future<Either<AppError, PostPreviews>> load(int page) {
    return Habr().findPosts(query, page: page, order: order);
  }
}

class UserPreviewsLoader extends PageLoader<Either<AppError, PostPreviews>> {
  final String username;

  UserPreviewsLoader(this.username);

  @override
  Future<Either<AppError, PostPreviews>> load(int page) {
    return Habr().userPosts(username, page: page);
  }
}
