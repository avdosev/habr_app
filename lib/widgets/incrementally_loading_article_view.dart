import 'package:flutter/material.dart';
import 'package:incrementally_loading_listview/incrementally_loading_listview.dart';
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

  @override
  Widget build(BuildContext context) {
    return IncrementallyLoadingListView(
      itemCount: () => previews.length,
      hasMore: () => pages < maxPages,
      itemBuilder: (BuildContext context, int index) {
        final loadingInProgress = ((loadingItems ?? false) && index == previews.length - 1);
        final preview = widget.postPreviewBuilder(context, previews[index]);
        return Column(
          children: [
            preview,
            if (index != previews.length-1)
              const Divider(height: 1,),
            if (loadingInProgress) ...[
              const Divider(height: 1,),
              const CircularItem()
            ]
          ]
        );
      },
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
      // separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

}