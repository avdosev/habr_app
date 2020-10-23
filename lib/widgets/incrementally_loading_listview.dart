import 'package:flutter/cupertino.dart';
import 'package:incrementally_loading_listview/incrementally_loading_listview.dart';

class SeparatedIncrementallyLoadingListView extends StatelessWidget {
  final IndexedWidgetBuilder separatorBuilder;
  final IndexedWidgetBuilder itemBuilder;
  final ItemCount itemCount;
  final OnLoadMore onLoadMore;
  final OnLoadMoreFinished onLoadMoreFinished;
  final HasMore hasMore;
  final LoadMore loadMore;

  SeparatedIncrementallyLoadingListView({
    this.separatorBuilder,
    this.itemBuilder,
    this.itemCount,
    this.onLoadMoreFinished,
    this.onLoadMore,
    this.hasMore,
    this.loadMore
  });

  Widget itemBuilderSeparated(BuildContext context, int index) {
    final isSeparator = index % 2 == 1;
    final separatorIndex = (index-1) ~/ 2;

    if (isSeparator)
      return separatorBuilder(context, separatorIndex);

    final itemIndex = index ~/ 2;
    return itemBuilder(context, itemIndex);
  }

  int itemCountSeparated() {
    final count =  itemCount();
    if (count == 0) {
      return 0;
    } else {
      return count * 2 - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IncrementallyLoadingListView(
        hasMore: hasMore,
        loadMore: loadMore,
        onLoadMore: onLoadMore,
        onLoadMoreFinished: onLoadMoreFinished,
        itemBuilder: itemBuilderSeparated,
        itemCount: itemCountSeparated
    );
  }
}