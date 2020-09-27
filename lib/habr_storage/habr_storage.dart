import 'package:habr_app/habr/habr.dart';
import 'cache_tables.dart';
import 'package:either_dart/either.dart';

export 'package:habr_app/habr/dto.dart';
export 'package:habr_app/habr/storage_interface.dart';

enum HabrFlow {

  saved,
  dayTop,
  weekTop,
  yearTop,
  time,
  news
}

/// Singleton cache_storage for habr api
class HabrStorage {
  final Habr api;
  final Cache cache;

  HabrStorage._privateConstructor():
      api = Habr(),
      cache = Cache()
  ;

  static final HabrStorage _instance = HabrStorage._privateConstructor();

  factory HabrStorage() {
    return _instance;
  }

  Future<Either<StorageError, PostPreviews>> posts({int page = 1, }) async {
    return api.posts(page: page);
  }

  Future<Either<StorageError, Post>> article(String id) async {
    try {
      final article = await api.article(id);
      return article;
    } catch(e) {
      final cachedPost = await cache.cachedPostDao.getPost(id);

      return Either.condLazy(
          cachedPost == null,
          () => StorageError(
              errCode: ErrorType.NotFound,
              message: "Article not found in local storage"),
          () => Post(
              id: cachedPost.id,
              title: cachedPost.title,
              body: cachedPost.body,),
      );
    }
  }

  Future addArticleInCache(String id) {
    return article(id).then((postOrError) => {
      postOrError.map((post) => _cacheArticle(post))
    });
  }

  Future<Either<StorageError, Comments>> comments(String articleId) async {
    return api.comments(articleId);
  }

  Future _cacheAuthor(Author author) async {
    return await cache.cachedAuthorDao.insertAuthor(
        CachedAuthor(
            id: author.id,
            nickname: author.alias,
            avatarUrl: author.avatar.url
        )
    );
  }

  Future _cacheArticle(Post post) async {
    if (await cache.cachedAuthorDao.getAuthor(post.author.id) == null)
      await _cacheAuthor(post.author);
    await cache.cachedPostDao.insertPost(CachedPost(
      id: post.id,
      authorId: post.author.id,
      title: post.title,
      body: post.body,
      publishTime: post.publishDate,
      insertTime: DateTime.now(),
    ));
  }
}
