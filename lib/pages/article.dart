import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:habr_app/habr_storage/habr_storage.dart';
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
  ValueNotifier<bool> showFloatingActionButton = ValueNotifier(false);
  ScrollController _controller = ScrollController();
  final PostStorage postStorage = PostStorage();

  _ArticlePageState();

  @override
  void initState() {
    super.initState();
    postStorage.articleId = articleId;
    _controller.addListener(floatingButtonShowListener);
  }

  Future shareArticle(BuildContext context) async {
    final RenderBox box = context.findRenderObject();
    await Share.share('https://habr.com/post/$articleId',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  Widget buildAppBarTitle(context) {
    String title = "";
    switch (postStorage.loadingState) {
      case LoadingState.inProgress:
        title = AppLocalizations.of(context).loading;
        break;
      case LoadingState.isFinally:
        title = postStorage.post.title;
        break;
      case LoadingState.isCorrupted:
        title = AppLocalizations.of(context).notLoaded;
        break;
    }
    return Text(title, overflow: TextOverflow.fade,);
  }

  void reload() {
    postStorage.reload();
  }

  Widget buildBody(BuildContext context) {
    switch (postStorage.loadingState) {
      case LoadingState.inProgress:
        return const Center(child: const CircularProgressIndicator());
      case LoadingState.isFinally:
        return ArticleView(article: postStorage.post, controller: _controller);
      case LoadingState.isCorrupted:
        switch (postStorage.lastError.errCode) {
          case ErrorType.ServerError:
            return const Center(child: const LotOfEntropy());
          default:
            return Center(child: LossInternetConnection(onPressReload: reload));
        }
        break;
      default:
        throw UnsupportedError("Loading state ${postStorage.loadingState} not supported");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: buildAppBarTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => shareArticle(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == MoreButtons.Cache) {
                HabrStorage().addArticleInCache(widget.articleId);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: MoreButtons.Cache,
                child: Text(MoreButtons.Cache),
              ),
            ],
          )
        ],
      ),
      body: Observer(
        builder: buildBody,
      ),
      floatingActionButton: Observer(
        builder: (context) {
          showFloatingActionButton.value = postStorage.loadingState == LoadingState.isFinally;
          return ValueListenableBuilder(
              valueListenable: showFloatingActionButton,
              builder: (BuildContext context, bool value, Widget child) =>
                  HideFloatingActionButton(
                    tooltip: AppLocalizations.of(context).comments,
                    visible: value,
                    child: const Icon(Icons.chat_bubble_outline),
                    onPressed: () => openCommentsPage(context, articleId),
                    duration: const Duration(milliseconds: 300),
                  )
          );
        }
      )
    );
  }

  void floatingButtonShowListener() {
    final needShow = _controller.position.userScrollDirection == ScrollDirection.forward;
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

  static const List<String> values = [
    Cache
  ];
}

class ArticleInfo extends StatelessWidget {
  final Post article;

  const ArticleInfo({this.article});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(child: Text(dateToStr(article.publishDate, Localizations.localeOf(context)))),
            SmallAuthorPreview(article.author),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        const SizedBox(height: 7,),
        Text(article.title, style: TextStyle(fontSize: 24), textAlign: TextAlign.center,),
      ],
    );
  }
}

class ArticleView extends StatelessWidget {
  final Post article;
  final ScrollController controller;

  const ArticleView({this.article, this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(10).copyWith(bottom: 20),
      controller: controller,
      children: [
        ArticleInfo(article: article,),
        SizedBox(height: 30,),
        HtmlView(article.body),
        SizedBox(height: 20,),
        CommentsButton(onPressed: () => openCommentsPage(context, article.id),)
      ],
    );
  }
}
