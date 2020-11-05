import 'filter.dart';
import 'package:habr_app/habr/dto.dart';

export 'filter.dart';

class NicknameAuthorFilter extends Filter<PostPreview> {
  final String nickname;

  NicknameAuthorFilter(this.nickname);

  @override
  bool filter(PostPreview postPreview) {
    return nickname == postPreview.author.alias;
  }
}

class ScoreArticleFilter extends Filter<PostPreview> {
  final int min;
  final int max;

  ScoreArticleFilter({this.min, this.max});

  @override
  bool filter(PostPreview obj) {
    return (min != null && obj.statistics.score < min) ||
        (max != null && obj.statistics.score > max);
  }
}
