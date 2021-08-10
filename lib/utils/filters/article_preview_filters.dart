import 'filter.dart';
import 'package:habr_app/models/post_preview.dart';

export 'filter.dart';

class NicknameAuthorFilter extends Filter<PostPreview> {
  final String nickname;

  const NicknameAuthorFilter(this.nickname);

  @override
  bool filter(PostPreview postPreview) {
    return nickname == postPreview.author.alias;
  }
}

class ScoreArticleFilter extends Filter<PostPreview> {
  final int min;
  final int max;

  const ScoreArticleFilter({this.min, this.max});

  @override
  bool filter(PostPreview obj) {
    return (min != null && obj.statistics.score < min) ||
        (max != null && obj.statistics.score > max);
  }
}

class CompanyNameFilter extends Filter<PostPreview> {
  final String companyName;

  const CompanyNameFilter(this.companyName);

  @override
  bool filter(PostPreview postPreview) {
    final l = companyName.toLowerCase();
    return postPreview.hubs
            ?.any((element) => element.toLowerCase().contains(l)) ??
        false;
  }
}
