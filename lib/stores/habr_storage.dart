import 'package:flutter/foundation.dart';
import 'package:habr_app/habr/habr.dart';
import 'package:habr_app/models/cached_post.dart';
import 'package:habr_app/models/models.dart';
import 'package:habr_app/stores/image_storage.dart';
import 'package:habr_app/utils/extensions/iterator_helper.dart';
import 'package:habr_app/utils/images_finder.dart';
import 'package:habr_app/utils/log.dart';
import 'package:either_dart/either.dart';
import 'package:habr_app/app_error.dart';
import 'package:hive/hive.dart';
import 'package:tuple/tuple.dart';

enum PostsFlow { saved, dayTop, weekTop, yearTop, time, news }

/// Singleton cache_storage for habr api
class HabrStorage {
  final Habr api;
  final ImageLocalStorage imgStore;

  final articles = Hive.lazyBox<CachedPost>('cached_articles');
  final authors = Hive.lazyBox<Author>('cached_authors');

  HabrStorage({@required this.api, @required this.imgStore});

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
      final cachedPost = await articles.get(id);
      final cachedAuthor =
          cachedPost != null ? await authors.get(cachedPost.authorId) : null;

      return Either.condLazy(
        cachedPost != null && cachedAuthor != null,
        () => AppError(
            errCode: ErrorType.NotFound,
            message: "Article not found in local storage"),
        () => Post(
          id: cachedPost.id,
          title: cachedPost.title,
          body: cachedPost.body,
          publishDate: cachedPost.publishDate,
          author: cachedAuthor,
        ),
      );
    }
    return articleOrError;
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
    final cachedPostsIds = articles.keys.cast<String>();
    for (var postId in cachedPostsIds) {
      await removeArticleFromCache(postId);
    }
  }

  Future<Either<AppError, Comments>> comments(String articleId) async {
    return api.comments(articleId).mapRightAsync(_checkCachedCommentsAuthors);
  }

  Future<Comments> _checkCachedCommentsAuthors(Comments comments) async {
    final authorsId = comments.comments.values
        .where((element) => element.notBanned)
        .map((comment) => comment.author?.id)
        .toSet();
    final cachedAuthors =
        await Future.wait(authorsId.map((e) => this.authors.get(e))).then(
            (value) => value.where((element) => element != null).toList());
    final authorById = Map.fromEntries(
        cachedAuthors.map((value) => MapEntry(value.id, value)));
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
    final cachedPosts = await Future.wait(
        this.articles.keys.map(this.articles.get).toList(growable: false));
    cachedPosts.sort((a, b) => a.insertDate.compareTo(b.insertDate));
    final cachedAuthors = await Future.wait(
        cachedPosts.map((post) => authors.get(post.authorId)));
    return Right(PostPreviews(
      previews:
          zip2<CachedPost, Author>(cachedPosts, cachedAuthors).map((item) {
        final post = item.item1;
        final author = item.item2;

        return PostPreview(
          id: post.id,
          tags: [],
          title: post.title,
          publishDate: post.publishDate,
          statistics: Statistics.zero(),
          author: author,
        );
      }),
      maxCountPages: 1,
    ));
  }

  Future _cacheAuthor(Author author) async {
    String avatarUrl;

    if (author.avatar.isNotDefault) {
      final maybeSavedImage = await imgStore.saveImage(author.avatar.url);
      avatarUrl = maybeSavedImage.fold((left) => null, (right) => right);
    }

    await authors.put(author.id, author);
  }

  Future _uncacheArticle(String articleId) async {
    final eitherPost = await article(articleId);
    if (eitherPost.isLeft) return;
    final post = eitherPost.right;
    await articles.delete(articleId);
    final urls = await compute(getImageUrlsFromHtml, post.body);

    await Future.wait(urls.map((url) => imgStore.deleteImage(url)));
  }

  Future _cacheArticle(Post post) async {
    if (await authors.get(post.author.id) == null)
      await _cacheAuthor(post.author);
    await articles.put(
        post.id,
        CachedPost(
          id: post.id,
          authorId: post.author.id,
          title: post.title,
          body: post.body,
          publishDate: post.publishDate,
          insertDate: DateTime.now(),
        ));
    logInfo('parse urls from html');
    final urls = await compute(getImageUrlsFromHtml, post.body);
    final cachedPaths =
        await Future.wait(urls.map((url) => imgStore.saveImage(url)));
    final allImagesCached = cachedPaths.every((element) => element.isRight);
    logInfo(allImagesCached ? "all images cached" : "not all images cached");
  }
}
