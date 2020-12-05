class AuthorAvatarInfo {
  final String url;
  const AuthorAvatarInfo({this.url});

  bool get isDefault => url == null || url.isEmpty;
  bool get isNotDefault => !isDefault;
}