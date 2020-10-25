import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:mobx/mobx.dart';

part 'article_store.g.dart';

class ArticlesStorage = ArticlesStorageBase with _$ArticlesStorage;

enum LoadingState {
  inProgress, isFinally, isCorrupted
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

  @action
  Future reload() async {
    maxPages = -1;
    pages = 0;
    loadItems = false;
    loadFirstPage();
  }

  @action
  Future loadFirstPage() async {
    firstLoading = LoadingState.inProgress;
    final firstPage = await HabrStorage().posts(page: 1, flow: PostsFlow.saved);
    firstLoading = firstPage.unite<LoadingState>((left) {
      return LoadingState.isCorrupted;
    }, (right) {
      previews.addAll(right.previews);
      maxPages = right.maxCountPages;
      pages = 1;
      return LoadingState.isFinally;
    });
  }

  Future<PostPreviews> loadPosts(int page) async {
    final postOrError = await HabrStorage().posts(page: page, flow: PostsFlow.saved);
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
    previews.addAll(nextPage.previews);
    pages = numberLoadingPage;
  }

  bool hasNextPages() {
    return pages < maxPages;
  }

  @action
  removeArticleFromCache(String id) {
    previews.removeWhere((preview) => preview.id == id);
    HabrStorage().removeArticleFromCache(id);
  }
}
