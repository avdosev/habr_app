import 'package:habr_app/models/models.dart';

AuthorAvatarInfo prepareAvatarUrl(String url) {
  if (url == null) return AuthorAvatarInfo(url: null);
  if (url.startsWith("//")) url = url.replaceFirst("//", "https://");
  return AuthorAvatarInfo(url: url);
}

Author parseAuthorFromJson(Map<String, dynamic> json) {
  return Author(
    id: json['id'],
    alias: json['alias'],
    avatar: prepareAvatarUrl(json['avatarUrl']),
  );
}

bool _commentIsBanned(Map<String, dynamic> json) {
  return json['author'] == null;
}

Comments parseCommentsFromJson(Map<String, dynamic> data) {
  return Comments(
    threads: (data['threads'] as List).cast<int>(),
    comments: (data['comments'] as Map<String, dynamic>).map<int,
        Comment>((key, value) {
      return MapEntry(int.parse(key), parseCommentFromJson(value));
    }),
  );
}

Comment parseCommentFromJson(Map<String, dynamic> json) {
  final isBanned = _commentIsBanned(json);
  return Comment(
      id: json['id'],
      parentId: json['parentId'],
      level: json['level'],
      banned: isBanned,
      timePublished: isBanned ? null : DateTime.parse(json['timePublished']),
      timeChanged: json['timeChanged'] == null
          ? null
          : DateTime.parse(json['timeChanged']),
      children: (json['children'] as List).cast<int>(),
      author: isBanned ? null : parseAuthorFromJson(json['author']),
      message: json['message']);
}

Post parsePostFromJson(Map<String, dynamic> data) {
  return Post(
    id: data['id'],
    title: data['titleHtml'],
    body: data['textHtml'],
    publishDate: DateTime.parse(data['timePublished']),
    author: parseAuthorFromJson(data['author']),
  );
}

PostPreviews parsePostPreviewsFromJson(Map<String, dynamic> data) {
  return PostPreviews(
    maxCountPages: data['pagesCount'],
    previews: data['articleIds'].map<PostPreview>((id) {
      final article = data['articleRefs'][id];
      return PostPreview(
          id: id,
          corporative: article['isCorporative'],
          title: _preparePostTitle(article['titleHtml']),
          tags: article['flows']
              .map<String>((flow) => flow['title'] as String)
              .toList(),
          publishDate: DateTime.parse(article['timePublished']),
          author: parseAuthorFromJson(article['author']),
          statistics: Statistics.fromJson(article['statistics']));
    }).toList(),
  );
}

String _preparePostTitle(String title) {
  return title
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
