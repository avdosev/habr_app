import 'package:flutter/material.dart';
import 'package:habr_app/utils/integer_to_text.dart';

typedef ValueToStringTransformer = String Function(int);

class Statistics extends StatelessWidget {
  final Widget leading;
  final int value;
  final TextStyle textStyle;
  final ValueToStringTransformer valueToStringTransformer;

  const Statistics.widget({
    @required this.value,
    @required this.leading,
    this.textStyle,
    ValueToStringTransformer valueTransformer})
      :
    valueToStringTransformer = valueTransformer ?? intToMetricPrefix
  ;

  Statistics.icon({
    @required IconData iconData,
    @required this.value,
    double size = 20,
    this.textStyle,
    ValueToStringTransformer valueTransformer})
      :
    valueToStringTransformer = valueTransformer ?? intToMetricPrefix,
    leading = Icon(iconData, size: size, color: Colors.grey)
  ;

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          leading,
          SizedBox(width: 5,),
          Text(valueToStringTransformer(value), style: textStyle,),
        ]
    );
  }
}

class StatisticsFavoritesIcon extends StatelessWidget {
  final int favorites;
  StatisticsFavoritesIcon(this.favorites);

  @override
  Widget build(BuildContext context) {
    return Statistics.icon(value: favorites, iconData: Icons.bookmark);
  }
}

class StatisticsScoreIcon extends StatelessWidget {
  final int score;

  Color scoreToColor(int score) {
    switch (score.sign) {
      case -1: return Colors.red[800];
      case 0 : return Colors.grey[600];
      case 1 : return Colors.green[800];
    }
  }

  StatisticsScoreIcon(this.score);

  @override
  Widget build(BuildContext context) {
    return Statistics.icon(
      iconData: Icons.equalizer,
      value: score,
      textStyle: TextStyle(color: scoreToColor(score)),
      valueTransformer: (value) {
        String res = intToMetricPrefix(value);
        if (value > 0) res = '+' + res;
        return res;
      },
    );
  }
}

class StatisticsViewsIcon extends StatelessWidget {
  final int views;
  StatisticsViewsIcon(this.views);

  @override
  Widget build(BuildContext context) {
    return Statistics.icon(
      iconData: Icons.remove_red_eye,
      value: views,
    );
  }
}

class StatisticsCommentsIcon extends StatelessWidget {
  final int comments;
  StatisticsCommentsIcon(this.comments);

  @override
  Widget build(BuildContext context) {
    return Statistics.icon(
      iconData: Icons.forum,
      value: comments,
    );
  }
}