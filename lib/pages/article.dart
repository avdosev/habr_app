import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:habr_app/models/models.dart' as Models;
import 'package:habr_app/models/models.dart';
import 'package:habr_app/stores/app_settings.dart';
import 'package:habr_app/stores/bookmarks_store.dart';
import 'package:habr_app/stores/loading_state.dart';
import 'package:habr_app/utils/date_to_text.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:share/share.dart';
import 'package:habr_app/models/post.dart';
import 'package:habr_app/app_error.dart';
import 'package:habr_app/stores/post_store.dart';

class ArticlePage extends StatefulWidget {
  final String articleId;

  ArticlePage({Key key, this.articleId}) : super(key: key);

  @override
  createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  String get articleId => widget.articleId;
  ValueNotifier<bool> showFloatingActionButton;
  ScrollController _controller;

  _ArticlePageState();

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    showFloatingActionButton = ValueNotifier(false);
    _controller.addListener(floatingButtonShowListener);
  }

  Future shareArticle(BuildContext context) async {
    final RenderBox box = context.findRenderObject();
    await Share.share('https://habr.com/post/$articleId',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  Widget buildAppBarTitle(context, PostStorage store) {
    String title;
    switch (store.loadingState) {
      case LoadingState.inProgress:
        return LoadAppBarTitle();
      case LoadingState.isFinally:
        title = store.post.title;
        break;
      case LoadingState.isCorrupted:
        title = AppLocalizations.of(context).notLoaded;
        break;
      default:
        title = "";
    }
    return Text(
      title,
      overflow: TextOverflow.fade,
    );
  }

  Widget buildBody(BuildContext context, PostStorage postStorage) {
    switch (postStorage.loadingState) {
      case LoadingState.inProgress:
        return const Center(child: const CircularProgressIndicator());
      case LoadingState.isFinally:
        return ArticleView(
          article: postStorage.post,
          controller: _controller,
        );
      case LoadingState.isCorrupted:
        switch (postStorage.lastError.errCode) {
          case ErrorType.ServerError:
            return const Center(child: const LotOfEntropy());
          default:
            return Center(
              child: LossInternetConnection(
                onPressReload: () => postStorage.reload(),
              ),
            );
        }
        break;
      default:
        throw UnsupportedError(
            "Loading state ${postStorage.loadingState} not supported");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final store = PostStorage(widget.articleId);
        store.reload();
        store.addListener(() {
          showFloatingActionButton.value =
              store.loadingState == LoadingState.isFinally;
        });
        return store;
      },
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Consumer<PostStorage>(
              builder: (context, store, _) => buildAppBarTitle(context, store),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => shareArticle(context),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (val) {
                  final store =
                      Provider.of<PostStorage>(context, listen: false);
                  switch (val) {
                    case MoreButtons.Cache:
                      HabrStorage().addArticleInCache(widget.articleId);
                      break;
                    case MoreButtons.Bookmark:
                      addBookMark(store);
                      break;
                    case MoreButtons.BackToBookmark:
                      returnToBookmark(store);
                      break;
                  }
                },
                itemBuilder: (context) => MoreButtons.values
                    .map((val) => PopupMenuItem(value: val, child: Text(val)))
                    .toList(),
              )
            ],
          ),
          body: Consumer<PostStorage>(
            builder: (context, store, _) => buildBody(context, store),
          ),
          floatingActionButton: ValueListenableBuilder(
            valueListenable: showFloatingActionButton,
            builder: (BuildContext context, bool value, Widget child) =>
                HideFloatingActionButton(
              tooltip: AppLocalizations.of(context).comments,
              visible: value,
              child: const Icon(Icons.chat_bubble_outline),
              onPressed: () => openCommentsPage(context, articleId),
              duration: const Duration(milliseconds: 300),
            ),
          ),
        );
      },
    );
  }

  void addBookMark(PostStorage postStorage) {
    if (postStorage.loadingState == LoadingState.isFinally) {
      final position = _controller.offset;
      final post = postStorage.post;
      final preview = PostPreview(
        id: articleId,
        title: post.title,
        tags: [],
        publishDate: post.publishDate,
        statistics: Models.Statistics.zero(),
        author: post.author,
      );
      BookmarksStore().addBookmark(articleId, position, preview);
    }
  }

  void returnToBookmark(PostStorage postStorage) {
    if (postStorage.loadingState == LoadingState.isFinally) {
      final position = BookmarksStore().getPosition(articleId);
      if (position != null) {
        int duration = (_controller.offset - position).abs().round();
        _controller.animateTo(position,
            duration: Duration(milliseconds: duration), curve: Curves.easeIn);
      }
    }
  }

  void floatingButtonShowListener() {
    final needShow =
        _controller.position.userScrollDirection == ScrollDirection.forward;
    if (needShow != showFloatingActionButton.value)
      showFloatingActionButton.value = needShow;
  }

  @override
  void dispose() {
    _controller.removeListener(floatingButtonShowListener);
    showFloatingActionButton.dispose();
    super.dispose();
  }
}

class MoreButtons {
  static const String Cache = "Сохранить";
  static const String Bookmark = "Запомнить позицию";
  static const String BackToBookmark = "Вернуться в позицию";

  static const List<String> values = [Cache, Bookmark, BackToBookmark];
}

class ArticleInfo extends StatelessWidget {
  final PostInfo article;

  const ArticleInfo({this.article});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(dateToStr(
                    article.publishDate, Localizations.localeOf(context)))),
            InkWell(
              child: SmallAuthorPreview(article.author),
              onTap: () => openUser(context, article.author.alias),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        const SizedBox(
          height: 7,
        ),
        Text(
          article.title,
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ArticleView extends StatelessWidget {
  final ParsedPost article;
  final ScrollController controller;

  const ArticleView({this.article, this.controller});

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettings>();
    final textAlign = appSettings.articleTextAlign;
    return ListView(
      padding: const EdgeInsets.all(10).copyWith(bottom: 20),
      controller: controller,
      children: [
        ArticleInfo(
          article: article,
        ),
        SizedBox(
          height: 30,
        ),
        HtmlView(article.parsedBody, textAlign: textAlign),
        SizedBox(
          height: 20,
        ),
        InkWell(
          child: Padding(
              padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
              child: MediumAuthorPreview(article.author)),
          onTap: () =>
              openUser(context, article.author.alias), // open user page
        ),
        SizedBox(
          height: 20,
        ),
        CommentsButton(
          onPressed: () => openCommentsPage(context, article.id),
        )
      ],
    );
  }
}
