import 'package:flutter/material.dart';
import 'package:habr_app/utils/message_notifier.dart';
import 'package:provider/provider.dart';
import 'package:habr_app/stores/habr_storage.dart';

import 'package:habr_app/models/author_info.dart';
import 'package:habr_app/stores/avatar_color_store.dart';
import 'package:habr_app/stores/user_info_store.dart';
import 'package:habr_app/stores/articles_store.dart';
import 'package:habr_app/widgets/incrementally_loading_listview.dart';
import '../app_error.dart';
import '../stores/loading_state.dart';
import 'package:habr_app/utils/page_loaders/preview_loader.dart';
import 'package:habr_app/widgets/widgets.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:habr_app/utils/date_to_text.dart';

class UserPage extends StatelessWidget {
  final String username;

  UserPage({required this.username});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) =>
                  ArticlesStorage(UserPreviewsLoader(this.username))),
          ChangeNotifierProvider(create: (_) {
            final store = UserInfoStorage(this.username);
            store.loadInfo();
            return store;
          }),
        ],
        child: Scaffold(
          appBar: AppBar(title: UserAppBarTitle()),
          body: UserBody(),
        ));
  }
}

class UserAppBarTitle extends StatelessWidget {
  Widget buildTitle(BuildContext context, UserInfoStorage store) {
    String? title;
    final userLoading = store.loadingState;
    switch (userLoading) {
      case LoadingState.inProgress:
        return LoadAppBarTitle();
      case LoadingState.isFinally:
        title = store.username;
        break;
      case LoadingState.isCorrupted:
        title = AppLocalizations.of(context)!.notLoaded;
        break;
      default:
        title = "";
    }
    return Text(title);
  }

  Widget build(BuildContext context) {
    return Consumer<UserInfoStorage>(
      builder: (context, store, child) => buildTitle(context, store),
    );
  }
}

class UserBody extends StatelessWidget {
  Widget build(BuildContext context) {
    return Consumer2<UserInfoStorage, ArticlesStorage>(
        builder: (context, userStore, articlesStore, _) =>
            mainBuilder(context, userStore, articlesStore));
  }

  Widget mainBuilder(BuildContext bodyContext, UserInfoStorage userStore,
      ArticlesStorage articlesStore) {
    final userLoad = userStore.loadingState;
    final previewsLoad = articlesStore.firstLoading;
    if (userLoad == LoadingState.inProgress) {
      return const Center(child: const CircularProgressIndicator());
    } else if (userLoad == LoadingState.isFinally) {
      if (userStore.info!.postCount == 0) {
        return Column(
          children: [
            AuthorInfoView(info: userStore.info!),
            Expanded(child: const Center(child: const EmptyContent())),
          ],
        );
      }
      if (previewsLoad == LoadingState.isFinally) {
        return buildLoadedBody(bodyContext, userStore, articlesStore);
      } else if (previewsLoad == LoadingState.inProgress) {
        return Column(
          children: [
            AuthorInfoView(info: userStore.info!),
            Expanded(
                child: const Center(child: const CircularProgressIndicator())),
          ],
        );
      }
    }
    final err = userStore.lastError ?? articlesStore.lastError!;
    switch (err.errCode) {
      case ErrorType.ServerError:
        return const Center(child: const LotOfEntropy());
      default:
        return Center(
          child: LossInternetConnection(
            onPressReload: () => reload(userStore, articlesStore),
          ),
        );
    }
  }

  void reload(UserInfoStorage userStore, ArticlesStorage articlesStore) {
    userStore.loadInfo();
    articlesStore.reload();
  }

  Widget buildLoadedBody(BuildContext bodyContext, UserInfoStorage userStore,
      ArticlesStorage articlesStore) {
    final habrStorage = bodyContext.watch<HabrStorage>();
    const authorInfoElementsCount = 1;
    return IncrementallyLoadingListView(
      itemBuilder: (context, index) {
        final previews = articlesStore.previews;
        if ((index - authorInfoElementsCount) >= previews.length &&
            articlesStore.loadItems) return Center(child: const CircularItem());
        if (index < authorInfoElementsCount) {
          return AuthorInfoView(info: userStore.info!);
        }
        final preview = previews[index - authorInfoElementsCount];
        return SlidableArchive(
          child: ArticlePreview(
            key: ValueKey("preview_" + preview.id),
            postPreview: preview,
            onPressed: (articleId) => openArticle(context, articleId),
          ),
          onArchive: () => habrStorage.addArticleInCache(preview.id).then(
              (res) => notifySnackbarText(
                  context, "${preview.title} ${res ? '' : 'не'} скачено")),
        );
      },
      separatorBuilder: (context, index) => const Hr(),
      itemCount: () =>
          articlesStore.previews.length +
          (articlesStore.loadItems ? 1 : 0) +
          authorInfoElementsCount,
      loadMore: articlesStore.loadNextPage,
      hasMore: articlesStore.hasNextPages,
    );
  }
}

class AuthorInfoView extends StatelessWidget {
  final AuthorInfo info;

  AuthorInfoView({required this.info});

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context)!;
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
          defaultColor:
              AvatarColorStore().getColor(info.alias, theme.brightness),
          borderWidth: 2,
        ),
        Text('@' + info.alias, style: TextStyle(color: theme.primaryColor)),
        if (info.fullName != null && info.fullName!.isNotEmpty)
          Text("a.k.a. ${info.fullName}"),
        Text(info.speciality == null || info.speciality!.isEmpty
            ? localization.user
            : info.speciality!),
        if (info.about != null) Text(info.about!),
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
