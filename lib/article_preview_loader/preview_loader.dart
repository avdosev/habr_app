import 'package:either_dart/either.dart';
import 'package:habr_app/habr/habr.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:habr_app/pages/pages.dart';
import 'page_loader.dart';

export 'page_loader.dart';

class CachedPreviewLoader extends FlowPreviewLoader {
  CachedPreviewLoader() : super(PostsFlow.saved);
}

class FlowPreviewLoader extends PageLoader<Either<StorageError, PostPreviews>> {
  final PostsFlow flow;

  FlowPreviewLoader(this.flow);

  Future<Either<StorageError, PostPreviews>> load(int page) {
    return HabrStorage().posts(page: page, flow: flow);
  }
}

class SearchLoader extends PageLoader<Either<StorageError, PostPreviews>> {
  final String query;
  final Order order;

  SearchLoader(SearchData info)
  : query = info.query,
    order = info.order;

  Future<Either<StorageError, PostPreviews>> load(int page) {
    return Habr().findPosts(query, page: page, order: order);
  }
}

