import 'package:flutter/material.dart';

class StatisticsFavoritesIcon extends StatelessWidget {
  final int favorites;
  final double size;
  StatisticsFavoritesIcon(this.favorites, {this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Icon(Icons.bookmark, size: size, color: Colors.grey,),
          SizedBox(width: 5,),
          Text(favorites.toString()),
        ]
    );
  }
}

class StatisticsScoreIcon extends StatelessWidget {
  final int score;
  final double size;
  StatisticsScoreIcon(this.score, {this.size = 20});

  @override
  Widget build(BuildContext context) {
    var iconText = score.toString();
    if (score > 0) iconText = '+' + iconText;
    final colors = {
      -1: Colors.red[800],
      0 : Colors.grey[600],
      1 : Colors.green[800],
    };
    return Row(
        children: [
          Icon(Icons.equalizer, size: size, color: Colors.grey,),
          SizedBox(width: 5,),
          // Icon(Icons.thumbs_up_down, size: size,), // maybe use this
          Text(iconText, style: TextStyle(color: colors[score.sign])),
        ]
    );
  }
}

class StatisticsViewsIcon extends StatelessWidget {
  final int views;
  final double size;
  StatisticsViewsIcon(this.views, {this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Icon(Icons.remove_red_eye, size: size, color: Colors.grey,),
          SizedBox(width: 5,),
          Text(views.toString(),),
        ]
    );
  }
}

class StatisticsCommentsIcon extends StatelessWidget {
  final int comments;
  final double size;
  StatisticsCommentsIcon(this.comments, {this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Icon(Icons.forum, size: size, color: Colors.grey,),
          SizedBox(width: 5,),
          Text(comments.toString()),
        ]
    );
  }
}