class AuthorAvatarInfo {
  final String url;
  final bool cached;
  const AuthorAvatarInfo({this.url, this.cached = false});

  bool get isDefault => url == null || url.isEmpty;
  bool get isNotDefault => !isDefault;
}