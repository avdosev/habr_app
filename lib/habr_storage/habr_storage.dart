import 'package:habr_app/habr/habr.dart';
import 'package:habr_app/habr/image_info.dart';
import 'cache_tables.dart';
import 'package:either_dart/either.dart';

export 'package:habr_app/habr/dto.dart';
export 'package:habr_app/habr/storage_interface.dart';

enum PostsFlow {
  saved,
  dayTop,
  weekTop,
  yearTop,
  time,
  news
}

Author _authorFromCachedAuthor(CachedAuthor author) {
  return Author(
    id: author.id,
    alias: author.nickname,
    avatar: ImageInfo(
      url: author.avatarUrl,
      store: ImageStoreType.Default // TODO: cache avatar
    )
  );
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

  Future<Either<StorageError, PostPreviews>> posts({int page = 1, PostsFlow flow}) async {
    if (flow == PostsFlow.saved) {
      return cachedPosts(page: page); // TODO
    }
    return api.posts(page: page);
  }

  Future<Either<StorageError, Post>> article(String id) async {
    final articleOrError = await api.article(id);
    if (articleOrError.isLeft) {
      final cachedPost = await cache.cachedPostDao.getPost(id);
      final cachedAuthor = cachedPost != null ? await cache.cachedAuthorDao.getAuthor(cachedPost.authorId) : null;

      return Either.condLazy(
          cachedPost != null && cachedAuthor != null,
          () => StorageError(
              errCode: ErrorType.NotFound,
              message: "Article not found in local storage"),
          () => Post(
              id: cachedPost.id,
              title: cachedPost.title,
              body: cachedPost.body,
              publishDate: cachedPost.publishTime,
              author: _authorFromCachedAuthor(cachedAuthor)
          ),
      );
    }
    return articleOrError;
  }

  Future addArticleInCache(String id) {
    return article(id).then((postOrError) => {
      postOrError.map((post) => _cacheArticle(post))
    });
  }

  Future removeArticleFromCache(String id) {
    return _uncacheArticle(id);
  }

  Future<Either<StorageError, Comments>> comments(String articleId) async {
    return api.comments(articleId);
  }

  Future<Either<StorageError, PostPreviews>> cachedPosts({int page = 1}) async {
    final pageSize = 10;
    final postsCount = await cache.cachedPostDao.count();
    final maxPages = (postsCount / pageSize).ceil();

    final cachedPosts = await cache.cachedPostDao.getAllPosts(page: page, count: pageSize);
    if (cachedPosts == null) return Left(StorageError(errCode: ErrorType.NotFound));
    return Right(
      PostPreviews(
        previews: cachedPosts.map<PostPreview>((cachedPost) {
          final author = cachedPost.author;
          final post = cachedPost.post;
          return PostPreview(
            id: post.id,
            tags: [],
            title: post.title,
            publishDate: post.publishTime,
            statistics: Statistics.zero(),
            author: _authorFromCachedAuthor(author),
          );
        }).toList(),
        maxCountPages: maxPages,
      )
    );
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

  Future _uncacheArticle(String articleId) async {
    await cache.cachedPostDao.deletePost(articleId);
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
