abstract class PageLoader<Page> {
  Future<Page> load(int page);
}
