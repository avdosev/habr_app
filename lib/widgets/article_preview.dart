import 'package:flutter/material.dart';
import 'package:habr_app/utils/date_to_text.dart';
import 'package:habr_app/models/post_preview.dart';

import 'small_author_preview.dart';
import 'statistics_icons.dart';

class ArticlePreview extends StatelessWidget {
  final PostPreview postPreview;
  final Function(String articleId) onPressed;

  ArticlePreview({Key key, @required this.postPreview, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upIconTextStyle = const TextStyle(fontSize: 15);
    final statisticIconTextStyle = const TextStyle(fontSize: 15);
    return InkWell(
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(
                          dateToStr(postPreview.publishDate,
                              Localizations.localeOf(context)),
                          style: upIconTextStyle)),
                  SmallAuthorPreview(postPreview.author,
                      textStyle: upIconTextStyle),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              const SizedBox(
                height: 7,
              ),
              Text(postPreview.title,
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  textAlign: TextAlign.left),
              const SizedBox(
                height: 10,
              ),
              Text(
                  postPreview.tags
                      .where((String el) => !el.startsWith('Блог компании'))
                      .join(', '),
                  style: const TextStyle(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatisticsScoreIcon(
                    postPreview.statistics.score,
                    textStyle: statisticIconTextStyle,
                  ),
                  StatisticsViewsIcon(
                    postPreview.statistics.readingCount,
                    textStyle: statisticIconTextStyle,
                  ),
                  StatisticsFavoritesIcon(
                    postPreview.statistics.favoritesCount,
                    textStyle: statisticIconTextStyle,
                  ),
                  StatisticsCommentsIcon(
                    postPreview.statistics.commentsCount,
                    textStyle: statisticIconTextStyle,
                  ),
                ],
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          )),
      onLongPress: () {}, // TODO: Настройки поста при долгом нажатии
      onTap: () => onPressed?.call(postPreview.id),
    );
  }
}
