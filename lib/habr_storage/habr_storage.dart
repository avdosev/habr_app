import 'package:flutter/foundation.dart';
import 'package:habr_app/habr/habr.dart';
import 'package:habr_app/models/models.dart';
import 'package:habr_app/habr_storage/image_storage.dart';
import 'package:habr_app/utils/images_finder.dart';
import 'package:habr_app/utils/workers/hasher.dart';
import 'package:habr_app/utils/log.dart';
import 'package:either_dart/either.dart';
import 'package:habr_app/app_error.dart';
import 'package:habr_app/utils/workers/image_loader.dart';

import 'cache_tables.dart';

enum PostsFlow { saved, dayTop, weekTop, yearTop, time, news }

/// Singleton cache_storage for habr api
class HabrStorage {
  final Habr api;
  final Cache cache;
  final ImageLocalStorage imgStore;

  HabrStorage._privateConstructor()
      : api = Habr(),
        cache = globalCache,
        imgStore = ImageLocalStorage(globalCache, MD5Hash(), ImageHttpLoader());

  static final HabrStorage _instance = HabrStorage._privateConstructor();

  factory HabrStorage() {
    return _instance;
  }

  Future<Either<AppError, PostPreviews>> posts(
      {int page = 1, PostsFlow flow}) async {
    if (flow == PostsFlow.saved) {
      return cachedPosts(page: page); // TODO: make flows
    }
    return api.posts(page: page);
  }

  Future<Either<AppError, Post>> article(String id) async {
    final articleOrError = await api.article(id);
    if (articleOrError.isLeft) {
      final cachedPost = await cache.cachedPostDao.getPost(id);
      final cachedAuthor = cachedPost != null
          ? await cache.cachedAuthorDao.getAuthor(cachedPost.authorId)
          : null;

      return Either.condLazy(
        cachedPost != null && cachedAuthor != null,
        () => AppError(
            errCode: ErrorType.NotFound,
            message: "Article not found in local storage"),
        () => Post(
            id: cachedPost.id,
            title: cachedPost.title,
            body: cachedPost.body,
            publishDate: cachedPost.publishTime,
            author: _authorFromCachedAuthor(cachedAuthor)),
      );
    }
    return articleOrError;
  }

  Author _authorFromCachedAuthor(CachedAuthor author) {
    return Author(
      id: author.id,
      alias: author.nickname,
      avatar: AuthorAvatarInfo(url: author.avatarUrl, cached: true),
      speciality: author.speciality,
    );
  }

  Future<bool> addArticleInCache(String id) {
    return article(id)
        .then((postOrError) =>
            postOrError.mapAsync((post) => _cacheArticle(post)))
        .then((cachedPost) => cachedPost.isRight);
  }

  Future removeArticleFromCache(String id) {
    return _uncacheArticle(id);
  }

  Future removeAllArticlesFromCache() async {
    final postsCount = await cache.cachedPostDao.count();
    final cachedPosts =
        await cache.cachedPostDao.getAllPosts(page: 1, count: postsCount);
    for (var post in cachedPosts) {
      await removeArticleFromCache(post.post.id);
    }
  }

  Future<Either<AppError, Comments>> comments(String articleId) async {
    return api
        .comments(articleId)
        .then((value) => value.mapAsync(_checkCachedCommentsAuthors));
  }

  Future<Comments> _checkCachedCommentsAuthors(Comments comments) async {
    final authorsId = comments.comments.values
        .where((element) => element.notBanned)
        .map((comment) => comment.author?.id)
        .toSet();
    final cachedAuthors = await cache.cachedAuthorDao.getAuthors(authorsId);
    final authors = cachedAuthors.map((e) => _authorFromCachedAuthor(e));
    final authorById =
        Map.fromEntries(authors.map((value) => MapEntry(value.id, value)));
    return Comments(
        comments: comments.comments.map((key, comment) {
          if (!comment.banned) {
            final cachedAuthor = authorById[comment.author];
            if (cachedAuthor != null) {
              return MapEntry(key, comment.copyWith(author: cachedAuthor));
            }
          }
          return MapEntry(key, comment);
        }),
        threads: comments.threads);
  }

  Future<Either<AppError, PostPreviews>> cachedPosts({int page = 1}) async {
    final pageSize = 10;
    final postsCount = await cache.cachedPostDao.count();
    final maxPages = (postsCount / pageSize).ceil();

    final cachedPosts =
        await cache.cachedPostDao.getAllPosts(page: page, count: pageSize);
    if (cachedPosts == null) return Left(AppError(errCode: ErrorType.NotFound));
    return Right(PostPreviews(
      previews: await Future.wait(
          cachedPosts.map<Future<PostPreview>>((cachedPost) async {
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
      })),
      maxCountPages: maxPages,
    ));
  }

  Future _cacheAuthor(Author author) async {
    String avatarUrl;

    if (author.avatar.isNotDefault) {
      final maybeSavedImage = await imgStore.saveImage(author.avatar.url);
      avatarUrl = maybeSavedImage.fold((left) => null, (right) => right);
    }

    await cache.cachedAuthorDao.insertAuthor(CachedAuthor(
      id: author.id,
      nickname: author.alias,
      avatarUrl: avatarUrl,
      speciality: author.speciality,
    ));
  }

  Future _uncacheArticle(String articleId) async {
    final eitherPost = await article(articleId);
    if (eitherPost.isLeft) return;
    final post = eitherPost.right;
    await cache.cachedPostDao.deletePost(articleId);
    final urls = await compute(getImageUrlsFromHtml, post.body);

    await Future.wait(urls.map((url) => imgStore.deleteImage(url)));
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
    logInfo('parse urls from html');
    final urls = await compute(getImageUrlsFromHtml, post.body);
    final cachedPaths =
        await Future.wait(urls.map((url) => imgStore.saveImage(url)));
    final allImagesCached = cachedPaths.every((element) => element.isRight);
    logInfo(allImagesCached ? "all images cached" : "not all images cached");
  }
}
