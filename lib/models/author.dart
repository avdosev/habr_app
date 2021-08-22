import 'author_avatar_info.dart';

class Author {
  final String id;
  final String alias;
  final String? fullName;
  final String? speciality;
  final AuthorAvatarInfo avatar;

  const Author({
    required this.id,
    required this.alias,
    required this.avatar,
    this.speciality,
    this.fullName,
  });
}
