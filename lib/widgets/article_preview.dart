import 'package:flutter/material.dart';
import 'package:habr_app/utils/date_to_text.dart';
import 'package:habr_app/habr_storage/habr_storage.dart';

import 'small_author_preview.dart';
import 'statistics_icons.dart';

class ArticlePreview extends StatelessWidget {
  final PostPreview postPreview;
  final Function(String articleId) onPressed;

  ArticlePreview({
    @required this.postPreview,
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            children: [
              Row(
                children: [
                  Text(dateToStr(postPreview.publishDate, Localizations.localeOf(context))),
                  SmallAuthorPreview(postPreview.author),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              const SizedBox(height: 7,),
              Text(postPreview.title,  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600), overflow: TextOverflow.visible, softWrap: true, textAlign: TextAlign.left),
              const SizedBox(height: 10,),
              Text(postPreview.tags.join(', '), overflow: TextOverflow.ellipsis, textAlign: TextAlign.left),
              const SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatisticsScoreIcon(postPreview.statistics.score),
                  StatisticsViewsIcon(postPreview.statistics.readingCount),
                  StatisticsFavoritesIcon(postPreview.statistics.favoritesCount),
                  StatisticsCommentsIcon(postPreview.statistics.commentsCount),
                ],
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          )
      ),
      onLongPress: () {}, // TODO: Настройки поста при долгом нажатии
      onTap: onPressed == null ? null : () {
        onPressed(postPreview.id);
      }
    );
  }
}