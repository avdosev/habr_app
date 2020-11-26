import 'package:either_dart/either.dart';
import 'package:mobx/mobx.dart';

import 'package:habr_app/article_preview_loader/page_loader.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:habr_app/filter/article_preview_filters.dart';
import 'package:habr_app/app_error.dart';

import 'loading_state.dart';

part 'article_store.g.dart';

class ArticlesStorage extends ArticlesStorageBase with _$ArticlesStorage {
  final PageLoader<Either<AppError, PostPreviews>> loader;
  final Filter<PostPreview> filter;

  ArticlesStorage(this.loader, {this.filter = const NoneFilter<PostPreview>()}) {
    loadFirstPage();
  }

  Future<Either<AppError, PostPreviews>> loadPage(int page) {
    return loader.load(page);
  }

  @override
  bool filterPreview(PostPreview preview) {
    return filter.filter(preview);
  }
}

abstract class ArticlesStorageBase with Store {
  @observable
  LoadingState firstLoading;
  @observable
  bool loadItems = false;
  @observable
  List<PostPreview> previews = [];

  int maxPages = -1;
  int pages = 0;
  AppError lastError;

  @action
  Future reload() async {
    maxPages = -1;
    pages = 0;
    loadItems = false;
    loadFirstPage();
  }

  Future<Either<AppError, PostPreviews>> loadPage(int page);
  bool filterPreview(PostPreview preview);

  @action
  Future loadFirstPage() async {
    firstLoading = LoadingState.inProgress;
    final firstPage = await loadPage(1);
    firstLoading = firstPage.unite<LoadingState>((left) {
      lastError = left;
      return LoadingState.isCorrupted;
    }, (right) {
      previews
          .addAll(right.previews.where((preview) => !filterPreview(preview)));
      maxPages = right.maxCountPages;
      pages = 1;
      return LoadingState.isFinally;
    });
  }

  Future<PostPreviews> loadPosts(int page) async {
    final postOrError = await loadPage(page);
    return postOrError.unite<PostPreviews>((err) {
      // TODO: informing user
      return PostPreviews(previews: [], maxCountPages: -1);
    }, (posts) => posts);
  }

  @action
  Future loadNextPage() async {
    final numberLoadingPage = pages + 1;
    loadItems = true;
    final nextPage = await loadPosts(numberLoadingPage);
    loadItems = false;
    previews
        .addAll(nextPage.previews.where((element) => !filterPreview(element)));
    pages = numberLoadingPage;
  }

  bool hasNextPages() {
    return pages < maxPages;
  }

  @action
  removePreview(String id) {
    previews.removeWhere((element) => element.id == id);
    previews = List()..addAll(previews);
  }

  @action
  removeAllPreviews() {
    previews = [];
  }
}
