import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';
import 'package:habr_app/models/author.dart';

import 'package:habr_app/models/author_info.dart';
import 'package:habr_app/stores/avatar_color_store.dart';
import 'package:habr_app/stores/user_info_store.dart';
import 'package:habr_app/stores/article_store.dart';
import 'package:habr_app/widgets/incrementally_loading_listview.dart';
import '../app_error.dart';
import '../stores/loading_state.dart';
import 'package:habr_app/utils/page_loaders/preview_loader.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:habr_app/utils/date_to_text.dart';

class UserPage extends StatefulWidget {
  final String username;

  UserPage({@required this.username});

  @override
  createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  ArticlesStorage articlesStorage;
  final userInfoStorage = UserInfoStorage();

  @override
  void initState() {
    super.initState();
    articlesStorage = ArticlesStorage(UserPreviewsLoader(widget.username));
    userInfoStorage.loadInfo(widget.username);
  }

  void reload() {
    userInfoStorage.loadInfo(widget.username);
    articlesStorage.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: buildAppBarTitle,
        ),
      ),
      body: Observer(
        builder: buildBody,
      ),
    );
  }

  Widget buildAppBarTitle(BuildContext context) {
    String title;
    final userLoading = userInfoStorage.loadingState;
    switch (userLoading) {
      case LoadingState.inProgress:
        return LoadAppBarTitle();
      case LoadingState.isFinally:
        title = widget.username;
        break;
      case LoadingState.isCorrupted:
        title = AppLocalizations.of(context).notLoaded;
        break;
      default:
        title = "";
    }
    return Text(title);
  }

  Widget buildBody(BuildContext bodyContext) {
    final userLoad = userInfoStorage.loadingState;
    final previewsLoad = articlesStorage.firstLoading;
    if (userLoad == LoadingState.inProgress) {
      return const Center(child: const CircularProgressIndicator());
    } else if (userLoad == LoadingState.isFinally) {
      if (userInfoStorage.info.postCount == 0) {
        return Column(
          children: [
            buildAuthorInfo(context),
            Expanded(
                child: const Center(child: const EmptyContent())),
          ],
        );
      }
      if (previewsLoad == LoadingState.isFinally) {
        return buildLoadedBody(bodyContext);
      } else if (previewsLoad == LoadingState.inProgress) {
        return Column(
          children: [
            buildAuthorInfo(context),
            Expanded(
                child: const Center(child: const CircularProgressIndicator())),
          ],
        );
      }
    }
    final err = userInfoStorage.lastError ?? articlesStorage.lastError;
    switch (err.errCode) {
      case ErrorType.ServerError:
        return const Center(child: const LotOfEntropy());
      default:
        return Center(child: LossInternetConnection(onPressReload: reload));
    }
  }

  Widget buildLoadedBody(BuildContext bodyContext) {
    const authorInfoElementsCount = 1;
    return IncrementallyLoadingListView(
      itemBuilder: (context, index) {
        final previews = articlesStorage.previews;
        if ((index-authorInfoElementsCount) >= previews.length && articlesStorage.loadItems)
          return Center(child: const CircularItem());
        if (index < authorInfoElementsCount) {
          return buildAuthorInfo(context);
        }
        final preview = previews[index - authorInfoElementsCount];
        return SlidableArchive(
          child: ArticlePreview(
            key: ValueKey("preview_" + preview.id),
            postPreview: preview,
            onPressed: (articleId) => openArticle(context, articleId),
          ),
          onArchive: () =>
              HabrStorage().addArticleInCache(preview.id).then((res) {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("${preview.title} ${res ? '' : 'не'} скачено")));
          }),
        );
      },
      separatorBuilder: (context, index) => const Hr(),
      itemCount: () =>
          articlesStorage.previews.length +
          (articlesStorage.loadItems ? 1 : 0) +
          authorInfoElementsCount,
      loadMore: articlesStorage.loadNextPage,
      hasMore: articlesStorage.hasNextPages,
    );
  }

  Widget buildAuthorInfo(BuildContext context) {
    final info = userInfoStorage.info;
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        AuthorAvatarIcon(
          avatar: info.avatar,
          height: 96,
          width: 96,
          radius: 10,
          defaultColor: AvatarColorStore().getColor(
              Author(
                alias: info.alias, // TODO: make full author
              ),
              theme.brightness),
          borderWidth: 2,
        ),
        Text('@' + info.alias, style: TextStyle(color: theme.primaryColor)),
        if (info.fullName != null && info.fullName.isNotEmpty)
          Text("a.k.a. ${info.fullName}"),
        Text(info.speciality == null || info.speciality?.isEmpty
            ? localization.user
            : info.speciality),
        if (info.about != null) Text(info.about),
        // Row(
        //   children: [
        //     Text(info.followCount)
        //   ],
        // ),
        Text("Был онлайн " + dateToStr(info.lastActivityTime, locale)),
        Text("Зарегистрировался " + dateToStr(info.registerTime, locale),
            style: theme.textTheme.bodyText1),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text("${localization.articles}, ${info.postCount} штук",
              style: Theme.of(context).textTheme.headline5),
        )
      ],
    );
  }
}
