import 'package:flutter/material.dart';
import 'package:habr_app/utils/integer_to_text.dart';

typedef ValueToStringTransformer = String Function(int);

class StatisticsIcon extends StatelessWidget {
  final IconData iconData;
  final int value;
  final double size;
  final TextStyle textStyle;
  final  valueToStringTransformer;

  const StatisticsIcon({
    @required this.value,
    @required this.iconData,
    this.textStyle,
    ValueToStringTransformer valueTransformer,
    this.size = 20})
      :
    valueToStringTransformer = valueTransformer ?? intToMetricPrefix
  ;

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Icon(iconData, size: size, color: Colors.grey,),
          SizedBox(width: 5,),
          Text(intToMetricPrefix(value), style: textStyle,),
        ]
    );
  }
}

class StatisticsFavoritesIcon extends StatelessWidget {
  final int favorites;
  StatisticsFavoritesIcon(this.favorites);

  @override
  Widget build(BuildContext context) {
    return StatisticsIcon(value: favorites, iconData: Icons.bookmark);
  }
}

class StatisticsScoreIcon extends StatelessWidget {
  final int score;
  StatisticsScoreIcon(this.score);

  @override
  Widget build(BuildContext context) {

    final colors = {
      -1: Colors.red[800],
      0 : Colors.grey[600],
      1 : Colors.green[800],
    };
    final textStyle = TextStyle(color: colors[score.sign]);
    return StatisticsIcon(
      iconData: Icons.equalizer,
      value: score,
      textStyle: textStyle,
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
    return StatisticsIcon(
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
    return StatisticsIcon(
      iconData: Icons.forum,
      value: comments,
    );
  }
}