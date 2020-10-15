import 'package:flutter/material.dart';
import 'package:habr_app/widgets/incrementally_loading_listview.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';

import 'circular_item.dart';

typedef PageLoader = Future<PostPreviews> Function(int page);
typedef PostPreviewBuilder = Widget Function(BuildContext context, PostPreview postPreview);

class IncrementallyLoadingArticleView extends StatefulWidget {
  final PostPreviewBuilder postPreviewBuilder;
  final PageLoader load;
  final PostPreviews initPage;

  IncrementallyLoadingArticleView({
    @required this.postPreviewBuilder,
    @required this.load,
    this.initPage
  });

  @override
  State<StatefulWidget> createState() =>
      _IncrementallyLoadingArticleViewState(initPage);
}

class _IncrementallyLoadingArticleViewState extends State<IncrementallyLoadingArticleView> {
  int pages;
  int maxPages;
  bool loadingItems = false;
  List<PostPreview> previews;

  _IncrementallyLoadingArticleViewState(
      PostPreviews initPage
      ) :
        previews = initPage?.previews ?? [],
        maxPages = initPage?.maxCountPages ?? -1,
        pages = initPage == null ? 0 : 1
  ;

  Widget itemBuilder(BuildContext context, int index) {
    final isLoadItem = (loadingItems && index == previews.length);
    if (isLoadItem) return Center(child: const CircularItem());
    final preview = widget.postPreviewBuilder(context, previews[index]);
    return preview;
  }

  int itemCount() {
    return previews.length + (loadingItems ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return SeparatedIncrementallyLoadingListView(
      itemCount: itemCount,
      hasMore: () => pages < maxPages,
      itemBuilder: itemBuilder,
      separatorBuilder: (BuildContext context, int index) =>
        const Divider(height: 1),
      loadMore: () async {
        final loaded = pages+1;
        final posts = await widget.load(loaded);
        setState(() {
          maxPages = posts.maxCountPages;
          pages = loaded;
          previews.addAll(posts.previews);
        });
      },
      onLoadMore: () {
        setState(() {
          loadingItems = true;
        });
      },
      onLoadMoreFinished: () {
        setState(() {
          loadingItems = false;
        });
      },
    );
  }

}